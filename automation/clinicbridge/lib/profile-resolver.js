const { createDb } = require('./db');

async function resolveAccessProfile(db, profileCode) {
  const sql = `
    SELECT pap.id, pap.profile_code, pap.doctor_id, pap.login_identifier, pap.credential_ref,
           pap.login_mode, pap.metadata AS access_metadata,
           pr.id AS platform_registry_id, pr.platform_name, pr.platform_code,
           pr.connector_code, pr.metadata AS platform_metadata,
           pas.secret_value, pas.is_encrypted
    FROM platform_access_profiles pap
    LEFT JOIN platform_registry pr ON pr.id = pap.platform_registry_id
    LEFT JOIN platform_access_secrets pas
      ON pas.access_profile_id = pap.id
     AND pas.secret_type = 'password'
     AND pas.status = 'active'
    WHERE pap.profile_code = ? AND pap.status = 'active'
    LIMIT 1
  `;
  return db.queryOne(sql, [profileCode]);
}

function parseMaybeJson(value) {
  if (!value) return {};
  if (typeof value === 'object') return value;
  try {
    return JSON.parse(value);
  } catch (_) {
    return {};
  }
}

function extractLoginUrl(profile) {
  const accessMetadata = parseMaybeJson(profile.access_metadata);
  const platformMetadata = parseMaybeJson(profile.platform_metadata);
  return accessMetadata.login_url || platformMetadata.login_url || null;
}

function resolvePassword(profile) {
  if (!profile.secret_value) {
    throw new Error(`No active password secret found for profile: ${profile.profile_code}`);
  }
  if (profile.is_encrypted) {
    throw new Error('Encrypted secret support not implemented yet');
  }
  return profile.secret_value;
}

async function resolveProfileWithDb(profileCode) {
  const db = await createDb();
  try {
    const profile = await resolveAccessProfile(db, profileCode);
    if (!profile) throw new Error(`Access profile not found: ${profileCode}`);
    return profile;
  } finally {
    await db.close();
  }
}

module.exports = {
  resolveAccessProfile,
  parseMaybeJson,
  extractLoginUrl,
  resolvePassword,
  resolveProfileWithDb,
};
