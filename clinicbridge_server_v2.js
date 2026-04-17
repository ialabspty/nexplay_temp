require('dotenv').config();
const express = require('express');
const https = require('https');
const mysql = require('mysql2/promise');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;

const VERIFY_TOKEN = process.env.META_VERIFY_TOKEN || '';
const META_TOKEN = process.env.META_ACCESS_TOKEN || '';
const DEFAULT_PHONE_NUMBER_ID = process.env.META_PHONE_NUMBER_ID || '';

const DB_HOST = process.env.DB_HOST || 'www.servialpa.com';
const DB_PORT = Number(process.env.DB_PORT || 3306);
const DB_NAME = process.env.DB_NAME || 'ClinicBridge';
const DB_USER = process.env.DB_USER || 'openclaw_admin';
const DB_PASSWORD = process.env.DB_PASSWORD || '';

const pool = mysql.createPool({
  host: DB_HOST,
  port: DB_PORT,
  user: DB_USER,
  password: DB_PASSWORD,
  database: DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

app.use(express.json({ limit: '2mb' }));

function uuid() {
  return crypto.randomUUID();
}

async function queryOne(sql, params = []) {
  const [rows] = await pool.execute(sql, params);
  return rows[0] || null;
}

async function queryAll(sql, params = []) {
  const [rows] = await pool.execute(sql, params);
  return rows;
}

async function sendWhatsAppText(phoneNumberId, to, body) {
  return new Promise((resolve, reject) => {
    if (!META_TOKEN) return reject(new Error('META_ACCESS_TOKEN no configurado'));
    const effectivePhoneNumberId = phoneNumberId || DEFAULT_PHONE_NUMBER_ID;
    if (!effectivePhoneNumberId) return reject(new Error('phone_number_id no configurado'));

    const payload = JSON.stringify({
      messaging_product: 'whatsapp',
      to,
      type: 'text',
      text: { body }
    });

    const options = {
      hostname: 'graph.facebook.com',
      path: `/v23.0/${effectivePhoneNumberId}/messages`,
      method: 'POST',
      headers: {
        Authorization: `Bearer ${META_TOKEN}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(JSON.parse(data));
        } else {
          reject(new Error(`Meta API ${res.statusCode}: ${data}`));
        }
      });
    });

    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

async function resolveChannel(phoneNumberId) {
  return queryOne(
    `SELECT tc.id AS channel_id, tc.tenant_id, tc.clinic_id, tc.phone_number_id, tc.display_phone_number,
            tc.display_name, t.tenant_key, t.brand_name, t.status AS tenant_status, c.name AS clinic_name
     FROM tenant_channels tc
     JOIN tenants t ON t.id = tc.tenant_id
     LEFT JOIN clinics c ON c.id = tc.clinic_id
     WHERE tc.phone_number_id = ? AND tc.status = 'active'
     LIMIT 1`,
    [phoneNumberId]
  );
}

async function getBranding(tenantId) {
  return queryOne(
    `SELECT public_name, greeting_message, tone_profile
     FROM tenant_branding
     WHERE tenant_id = ?
     ORDER BY id DESC
     LIMIT 1`,
    [tenantId]
  );
}

async function getDoctors(clinicId) {
  return queryAll(
    `SELECT id, full_name, metadata
     FROM doctors
     WHERE clinic_id = ? AND status = 'active'
     ORDER BY full_name`,
    [clinicId]
  );
}

async function getLocation(clinicId) {
  return queryOne(
    `SELECT name, address_line1, city, country_code
     FROM locations
     WHERE clinic_id = ? AND status = 'active'
     ORDER BY id ASC
     LIMIT 1`,
    [clinicId]
  );
}

async function getSchedules(clinicId) {
  return queryAll(
    `SELECT d.full_name, ds.weekday, ds.start_time, ds.end_time
     FROM doctor_schedules ds
     JOIN doctors d ON d.id = ds.doctor_id
     WHERE d.clinic_id = ? AND d.status = 'active' AND ds.status = 'active'
     ORDER BY d.full_name, ds.weekday, ds.start_time`,
    [clinicId]
  );
}

async function getInsurances(clinicId) {
  return queryAll(
    `SELECT d.full_name, ai.insurance_name
     FROM accepted_insurances ai
     LEFT JOIN doctors d ON d.id = ai.doctor_id
     WHERE ai.clinic_id = ? AND ai.status = 'active'
     ORDER BY d.full_name, ai.insurance_name`,
    [clinicId]
  );
}

async function getServices(clinicId) {
  return queryAll(
    `SELECT code, name, listed_price, price_mode, metadata
     FROM services
     WHERE clinic_id = ? AND is_active = 1 AND public_enabled = 1
     ORDER BY name`,
    [clinicId]
  );
}

function weekdayName(n) {
  const map = {
    1: 'lunes', 2: 'martes', 3: 'miércoles', 4: 'jueves', 5: 'viernes', 6: 'sábado', 7: 'domingo'
  };
  return map[n] || `día ${n}`;
}

function formatTime(value) {
  if (!value) return '';
  return String(value).slice(0, 5);
}

async function buildReply(channel, text) {
  const normalized = (text || '').toLowerCase().trim();
  const branding = await getBranding(channel.tenant_id);
  const greeting = branding?.greeting_message || `Bienvenido a ${channel.brand_name}, ¿cómo podemos ayudarte?`;

  if (!normalized) return { body: greeting, source: 'hardcoded' };

  if (normalized.includes('ubicación') || normalized.includes('ubicacion') || normalized.includes('dirección') || normalized.includes('direccion') || normalized.includes('dónde') || normalized.includes('donde')) {
    const loc = await getLocation(channel.clinic_id);
    if (loc) {
      return {
        body: `Estamos en ${loc.address_line1}, ${loc.city}.`,
        source: 'db'
      };
    }
    return { body: greeting, source: 'hardcoded' };
  }

  if (normalized.includes('horario') || normalized.includes('atienden') || normalized.includes('horarios')) {
    const rows = await getSchedules(channel.clinic_id);
    if (rows.length) {
      const grouped = new Map();
      for (const row of rows) {
        const arr = grouped.get(row.full_name) || [];
        arr.push(`${weekdayName(row.weekday)} de ${formatTime(row.start_time)} a ${formatTime(row.end_time)}`);
        grouped.set(row.full_name, arr);
      }
      const body = Array.from(grouped.entries())
        .map(([name, times]) => `${name}: ${times.join('; ')}`)
        .join('\n');
      return { body: `Horarios vigentes:\n${body}`, source: 'db' };
    }
    return { body: greeting, source: 'hardcoded' };
  }

  if (normalized.includes('seguro') || normalized.includes('seguros') || normalized.includes('mapfre') || normalized.includes('blue cross')) {
    const rows = await getInsurances(channel.clinic_id);
    if (rows.length) {
      const grouped = new Map();
      for (const row of rows) {
        const key = row.full_name || 'Clínica';
        const arr = grouped.get(key) || [];
        arr.push(row.insurance_name);
        grouped.set(key, arr);
      }
      const body = Array.from(grouped.entries())
        .map(([name, ins]) => `${name}: ${ins.join(', ')}`)
        .join('\n');
      return { body: `Seguros aceptados:\n${body}`, source: 'db' };
    }
    return { body: greeting, source: 'hardcoded' };
  }

  if (normalized.includes('precio') || normalized.includes('consulta') || normalized.includes('cuánto cuesta') || normalized.includes('cuanto cuesta')) {
    const services = await getServices(channel.clinic_id);
    const consulta = services.find((s) => s.code === 'consulta-inicial');
    if (consulta) {
      let priceText = 'La consulta tiene un valor oficial de B/.100.';
      try {
        const meta = consulta.metadata ? JSON.parse(consulta.metadata) : {};
        if (meta?.discount_jubilados && meta?.precio_jubilado) {
          priceText += ` Para jubilados aplica ${meta.discount_jubilados}% de descuento y queda en B/.${Number(meta.precio_jubilado).toFixed(0)}.`;
        }
      } catch {}
      return { body: priceText, source: 'db' };
    }
    return { body: greeting, source: 'hardcoded' };
  }

  if (normalized.includes('cita') || normalized.includes('agendar') || normalized.includes('agenda')) {
    const doctors = await getDoctors(channel.clinic_id);
    if (doctors.length) {
      const lines = doctors.map((d) => {
        let bookingUrl = null;
        try {
          const meta = d.metadata ? JSON.parse(d.metadata) : {};
          bookingUrl = meta.booking_url || null;
        } catch {}
        return bookingUrl ? `${d.full_name}: ${bookingUrl}` : `${d.full_name}`;
      });
      return {
        body: `Para agendar, puedes usar los enlaces oficiales:\n\n${lines.join('\n')}`,
        source: 'db'
      };
    }
    return { body: greeting, source: 'hardcoded' };
  }

  if (normalized.includes('servicio') || normalized.includes('servicios')) {
    const services = await getServices(channel.clinic_id);
    if (services.length) {
      return {
        body: `Servicios disponibles:\n${services.map((s) => `- ${s.name}`).join('\n')}`,
        source: 'db'
      };
    }
  }

  return {
    body: `${greeting} Puedo ayudarte con servicios, precio oficial de consulta, seguros aceptados, horarios, ubicación y enlaces de agenda.`,
    source: 'hardcoded'
  };
}

async function findOrCreateContact(phone, name) {
  let contact = await queryOne(`SELECT * FROM contacts WHERE phone = ? LIMIT 1`, [phone]);
  if (contact) return contact;

  const contactUuid = uuid();
  await pool.execute(
    `INSERT INTO contacts (uuid, display_name, phone, contact_type, source_channel, metadata)
     VALUES (?, ?, ?, 'person', 'whatsapp', ?)`,
    [contactUuid, name || phone, phone, JSON.stringify({})]
  );
  return queryOne(`SELECT * FROM contacts WHERE uuid = ? LIMIT 1`, [contactUuid]);
}

async function findOrCreateConversation(contactId, tenantId, clinicId, externalChatId) {
  let convo = await queryOne(
    `SELECT * FROM conversations
     WHERE contact_id = ? AND tenant_id <=> ? AND clinic_id <=> ? AND channel = 'whatsapp' AND status IN ('open','pending')
     ORDER BY id DESC LIMIT 1`,
    [contactId, tenantId, clinicId]
  );
  if (convo) return convo;

  const convoUuid = uuid();
  await pool.execute(
    `INSERT INTO conversations (uuid, tenant_id, clinic_id, contact_id, channel, external_chat_id, status, metadata)
     VALUES (?, ?, ?, ?, 'whatsapp', ?, 'open', ?)`,
    [convoUuid, tenantId, clinicId, contactId, externalChatId || null, JSON.stringify({})]
  );
  return queryOne(`SELECT * FROM conversations WHERE uuid = ? LIMIT 1`, [convoUuid]);
}

async function insertMessage(conversationId, direction, senderType, senderRef, content, providerMessageId, status, metadata = {}) {
  const messageUuid = uuid();
  await pool.execute(
    `INSERT INTO messages (conversation_id, uuid, direction, sender_type, sender_ref, content, content_type, provider_message_id, status, metadata)
     VALUES (?, ?, ?, ?, ?, ?, 'text', ?, ?, ?)`,
    [conversationId, messageUuid, direction, senderType, senderRef, content, providerMessageId || null, status, JSON.stringify(metadata)]
  );
  return messageUuid;
}

async function logResolution(channel, conversationId, inboundMessageId, sourceUsed, success, extras = {}) {
  await pool.execute(
    `INSERT INTO message_resolution_logs
     (tenant_id, clinic_id, channel_id, conversation_id, inbound_message_id, source_used, provider_key, model_key, purpose, adapter_used,
      token_usage_in, token_usage_out, cost_estimate, fallback_triggered, response_latency_ms, success, error_message, metadata)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      channel.tenant_id,
      channel.clinic_id,
      channel.channel_id,
      conversationId,
      inboundMessageId,
      sourceUsed,
      extras.provider_key || null,
      extras.model_key || null,
      extras.purpose || null,
      extras.adapter_used || null,
      extras.token_usage_in || null,
      extras.token_usage_out || null,
      extras.cost_estimate || null,
      extras.fallback_triggered ? 1 : 0,
      extras.response_latency_ms || null,
      success ? 1 : 0,
      extras.error_message || null,
      JSON.stringify(extras.metadata || {})
    ]
  );
}

app.get('/webhooks/meta-whatsapp', (req, res) => {
  const mode = req.query['hub.mode'];
  const token = req.query['hub.verify_token'];
  const challenge = req.query['hub.challenge'];

  if (mode === 'subscribe' && token === VERIFY_TOKEN) {
    return res.status(200).send(challenge);
  }

  return res.sendStatus(403);
});

app.post('/webhooks/meta-whatsapp', async (req, res) => {
  console.log('Incoming webhook:', JSON.stringify(req.body, null, 2));
  res.status(200).send('EVENT_RECEIVED');

  const started = Date.now();

  try {
    const entry = req.body?.entry?.[0];
    const change = entry?.changes?.[0];
    const value = change?.value;
    const message = value?.messages?.[0];

    if (!message || message.type !== 'text') return;

    const phoneNumberId = value?.metadata?.phone_number_id;
    const from = message.from;
    const body = message.text?.body || '';
    const inboundMessageId = message.id;
    const profileName = value?.contacts?.[0]?.profile?.name || from;

    const channel = await resolveChannel(phoneNumberId);
    if (!channel) {
      console.error(`No active channel found for phone_number_id=${phoneNumberId}`);
      return;
    }

    const contact = await findOrCreateContact(from, profileName);
    const conversation = await findOrCreateConversation(contact.id, channel.tenant_id, channel.clinic_id, from);

    await insertMessage(conversation.id, 'inbound', 'contact', from, body, inboundMessageId, 'received', {
      phone_number_id: phoneNumberId,
      profile_name: profileName
    });

    const reply = await buildReply(channel, body);
    const result = await sendWhatsAppText(phoneNumberId, from, reply.body);
    const outboundMessageId = result?.messages?.[0]?.id || null;

    await insertMessage(conversation.id, 'outbound', 'agent', channel.tenant_key, reply.body, outboundMessageId, 'sent', {
      source_used: reply.source,
      phone_number_id: phoneNumberId
    });

    await logResolution(channel, conversation.id, inboundMessageId, reply.source, true, {
      response_latency_ms: Date.now() - started,
      metadata: { outbound_message_id: outboundMessageId }
    });

    console.log('Outgoing message result:', JSON.stringify(result));
  } catch (error) {
    console.error('Reply error:', error.message);
    try {
      const entry = req.body?.entry?.[0];
      const change = entry?.changes?.[0];
      const value = change?.value;
      const message = value?.messages?.[0];
      const phoneNumberId = value?.metadata?.phone_number_id;
      const channel = phoneNumberId ? await resolveChannel(phoneNumberId) : null;
      if (channel && message?.id) {
        await logResolution(channel, null, message.id, 'hardcoded', false, {
          response_latency_ms: Date.now() - started,
          error_message: error.message,
          fallback_triggered: true
        });
      }
    } catch {}
  }
});

app.get('/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ ok: true, service: 'clinicbridge-webhook-v2', db: true });
  } catch (error) {
    res.status(500).json({ ok: false, service: 'clinicbridge-webhook-v2', db: false, error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`ClinicBridge webhook v2 listening on port ${PORT}`);
});
