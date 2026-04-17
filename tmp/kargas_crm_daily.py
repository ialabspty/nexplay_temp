import json, re, requests
from datetime import datetime
from google.oauth2 import service_account
from googleapiclient.discovery import build

SERVICE_ACCOUNT_FILE = '/home/alexander-ortega/.openclaw/workspace/agents/hq/internal/tmp/kargapty-service-account.json'
SHEET_ID = '1q1dDLWUz_Hw1f_P-DARhj0-NecvKzjWmwtmLd8QOGBc'
CRM_LOGIN = 'https://crm.panacargalogistic.com/authentication/login'
CRM_MGMT = 'https://crm.panacargalogistic.com/client/warehouse/management'
CRM_ENDPOINT = 'https://crm.panacargalogistic.com/consignee/warehouse/my_receipts/all/all'
CRM_EMAIL = 'kargapty@gmail.com'
CRM_PASSWORD = 'kargapty'
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']
now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

creds = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)
service = build('sheets', 'v4', credentials=creds, cache_discovery=False)

sp = service.spreadsheets().values()
trackings_rows = sp.get(spreadsheetId=SHEET_ID, range='trackings!A:ZZ').execute().get('values', [])
ops_rows = sp.get(spreadsheetId=SHEET_ID, range='operaciones!A:ZZ').execute().get('values', [])
track_headers = trackings_rows[0]
ops_headers = ops_rows[0]
thi = {h:i for i,h in enumerate(track_headers)}
ohi = {h:i for i,h in enumerate(ops_headers)}

def norm(v): return str(v).strip() if v is not None else ''
def pad(row,n): return (row + ['']*n)[:n]

def crm_fetch_all():
    s = requests.Session()
    login_page = s.get(CRM_LOGIN, timeout=30).text
    csrf = re.search(r'name="csrf_token_name" value="([^"]+)"', login_page).group(1)
    s.post(CRM_LOGIN, data={'csrf_token_name': csrf, 'email': CRM_EMAIL, 'password': CRM_PASSWORD, 'remember': 'on'}, timeout=30)
    headers = {'X-Requested-With': 'XMLHttpRequest', 'Referer': CRM_MGMT}
    first = s.get(CRM_ENDPOINT, headers=headers, timeout=60, params={'start':0,'length':500}).json()
    total = int(first.get('recordsTotal') or len(first.get('data', [])))
    data = first.get('data', [])
    for start in range(len(data), total, 500):
        data.extend(s.get(CRM_ENDPOINT, headers=headers, timeout=60, params={'start':start,'length':500}).json().get('data', []))
    return data, total

crm_data,total = crm_fetch_all()
status8 = [r for r in crm_data if int(r.get('status') or 0)==8]

trackings_by_tracking = {}
for idx,row in enumerate(trackings_rows[1:], start=2):
    row=pad(row,len(track_headers)); tr=norm(row[thi['tracking']]) if 'tracking' in thi else ''
    if tr: trackings_by_tracking[tr]=(idx,row)
ops_by_tracking = {}
for idx,row in enumerate(ops_rows[1:], start=2):
    row=pad(row,len(ops_headers)); tr=norm(row[ohi['tracking']]) if 'tracking' in ohi else ''
    if tr and tr not in ops_by_tracking: ops_by_tracking[tr]=(idx,row)

trackings_updates=[]; trackings_appends=[]; ops_updates=[]; ops_appends=[]
created_trackings=updated_trackings=created_ops=updated_ops=duplicates_avoided=0
errors=[]

for r in status8:
    tr = norm(r.get('tracking'))
    if not tr:
        errors.append('Fila CRM sin tracking en status 8')
        continue
    # tracking row
    if tr in trackings_by_tracking:
        rownum,row = trackings_by_tracking[tr]
        row = pad(row,len(track_headers))
        updated_trackings += 1
    else:
        rownum,row = None,['']*len(track_headers)
        created_trackings += 1
    for k,v in {
        'tracking': tr,
        'status_proveedor': '8',
        'mode': norm(r.get('mode_name')),
        'wr': norm(r.get('receipt')),
        'shipment': norm(r.get('shipment')),
        'fecha_registrado': norm(r.get('datecreated')),
        'tienda_comercio': norm(r.get('shipper')),
        'factura': norm(r.get('invoice_number')),
        'pcs': norm(r.get('total_pcs') or r.get('total_items')),
        'unidad': norm(r.get('unit')),
        'peso': norm(r.get('total_weight')),
        'length': norm(r.get('cargo_length')),
        'width': norm(r.get('cargo_width')),
        'height': norm(r.get('cargo_height')),
        'volumen': norm(r.get('vol_weight')),
        'cubiclaje': norm(r.get('total_cft')),
        'costo_tarifa': norm(r.get('cargo_amount')),
        'ultima_actualizacion': now,
    }.items():
        if k in thi: row[thi[k]] = v
    if rownum: trackings_updates.append({'range':f'trackings!A{rownum}:ZZ{rownum}','values':[row]})
    else: trackings_appends.append(row)

    # operation row
    if tr in ops_by_tracking:
        rownum,row = ops_by_tracking[tr]
        row = pad(row,len(ops_headers))
        updated_ops += 1
        duplicates_avoided += 1
    else:
        rownum,row = None,['']*len(ops_headers)
        created_ops += 1
    base={
        'tracking': tr,
        'modo': norm(r.get('mode_name')),
        'fuente_creacion': 'crm_diario',
        'origen_confirmacion': 'crm',
        'tracking_estado_crm': '8',
        'titulo_estado_crm': 'Recibido por KargasPTY',
        'estado_operacion': 'pendiente',
        'operacion_unica_key': tr,
        'fecha_recepcion_kargas': norm(r.get('datecreated')),
        'fecha_operacion': norm(r.get('datecreated')),
    }
    for k,v in base.items():
        if k in ohi and (not norm(row[ohi[k]]) or k in ['tracking_estado_crm','titulo_estado_crm','origen_confirmacion']):
            row[ohi[k]] = v
    if rownum: ops_updates.append({'range':f'operaciones!A{rownum}:ZZ{rownum}','values':[row]})
    else: ops_appends.append(row)

# batch write minimal requests
if trackings_updates or ops_updates:
    service.spreadsheets().values().batchUpdate(
        spreadsheetId=SHEET_ID,
        body={'valueInputOption':'USER_ENTERED','data':trackings_updates + ops_updates}
    ).execute()
if trackings_appends:
    sp.append(spreadsheetId=SHEET_ID, range='trackings!A:ZZ', valueInputOption='USER_ENTERED', insertDataOption='INSERT_ROWS', body={'values':trackings_appends}).execute()
if ops_appends:
    sp.append(spreadsheetId=SHEET_ID, range='operaciones!A:ZZ', valueInputOption='USER_ENTERED', insertDataOption='INSERT_ROWS', body={'values':ops_appends}).execute()

print(json.dumps({
 'hora_ejecucion': now,
 'trackings_revisados': total,
 'status_8_detectados': len(status8),
 'registros_creados_trackings': created_trackings,
 'registros_actualizados_trackings': updated_trackings,
 'operaciones_creadas': created_ops,
 'operaciones_actualizadas': updated_ops,
 'duplicados_evitados': duplicates_avoided,
 'errores': errors,
 'trackings_status_8': [norm(r.get('tracking')) for r in status8],
}, ensure_ascii=False, indent=2))
