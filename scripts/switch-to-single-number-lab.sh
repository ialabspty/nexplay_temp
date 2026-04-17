#!/usr/bin/env bash
set -Eeuo pipefail

CONFIG_DIR="$HOME/.openclaw"
TARGET_CONFIG="$CONFIG_DIR/openclaw.json"
SOURCE_CONFIG="/home/alexander-ortega/.openclaw/workspace/docs/openclaw.single-number-lab-minimal.json5"
TIMESTAMP="$(date +%F-%H%M%S)"
BACKUP_CONFIG="$CONFIG_DIR/openclaw.json.backup.$TIMESTAMP"
ROLLBACK_DONE=0

log() {
  printf '[lab-switch] %s\n' "$*"
}

fail() {
  printf '[lab-switch][error] %s\n' "$*" >&2
  exit 1
}

rollback() {
  if [[ $ROLLBACK_DONE -eq 1 ]]; then
    return 0
  fi

  if [[ -f "$BACKUP_CONFIG" ]]; then
    log "Restaurando backup: $BACKUP_CONFIG"
    cp "$BACKUP_CONFIG" "$TARGET_CONFIG"
    if ! openclaw gateway restart; then
      log "Fallo al reiniciar OpenClaw durante rollback"
    fi
    ROLLBACK_DONE=1
  else
    log "No se encontró backup para rollback: $BACKUP_CONFIG"
  fi
}

on_error() {
  local exit_code=$?
  log "Se detectó un error. Ejecutando rollback automático."
  rollback
  exit "$exit_code"
}

trap on_error ERR

[[ -d "$CONFIG_DIR" ]] || fail "No existe el directorio de configuración: $CONFIG_DIR"
[[ -f "$TARGET_CONFIG" ]] || fail "No existe la config actual: $TARGET_CONFIG"
[[ -f "$SOURCE_CONFIG" ]] || fail "No existe la config de laboratorio: $SOURCE_CONFIG"

log "Creando backup: $BACKUP_CONFIG"
cp "$TARGET_CONFIG" "$BACKUP_CONFIG"

log "Aplicando config de laboratorio mínima"
cp "$SOURCE_CONFIG" "$TARGET_CONFIG"

log "Reiniciando OpenClaw"
openclaw gateway restart

log "Verificando gateway"
GATEWAY_STATUS="$(openclaw gateway status)"
printf '%s\n' "$GATEWAY_STATUS"

if ! grep -Eqi 'running|active|started|listening|online' <<<"$GATEWAY_STATUS"; then
  fail "La salida de openclaw gateway status no parece saludable"
fi

log "Verificando canales"
CHANNELS_STATUS="$(openclaw channels status --probe)"
printf '%s\n' "$CHANNELS_STATUS"

if grep -Eqi 'error|failed|unhealthy|not running|unavailable' <<<"$CHANNELS_STATUS"; then
  fail "La salida de openclaw channels status --probe indica un posible fallo"
fi

trap - ERR

log "Cambio completado"
log "Backup creado: $BACKUP_CONFIG"
log "Config activa: $TARGET_CONFIG"
log "Siguiente paso: prueba por WhatsApp con mensajes técnicos y naturales"
