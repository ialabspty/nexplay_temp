# Bloque operativo — Onboarding de cliente nuevo KargasPTY

## Objetivo
Registrar correctamente a un cliente nuevo, definir su zona y tarifa base, y entregarle la información necesaria para que pueda comprar y recibir su mercancía correctamente.

## 1. Identificación del cliente
El cliente se identifica por:
- **teléfono**

Formato recomendado:
- `+507XXXXXXXX`

Si el teléfono ya existe en `clientes`:
- no se registra de nuevo
- se usa su ficha existente

Si no existe:
- se crea como cliente nuevo

## 2. Datos mínimos de registro
Para dar de alta al cliente se debe obtener:

- `nombre_cliente`
- `telefono`
- `zona_entrega_default`
- `observaciones` *(si aplica)*

La zona de entrega se define con base en el sitio donde el cliente indica que recibirá la mercancía.

## 3. Alta en la hoja `clientes`
Crear registro con:

- `cliente_id`
- `telefono`
- `nombre_cliente`
- `zona_entrega_default`
- `tarifa_especial_activa = no` *(salvo que ya exista acuerdo especial)*
- `observaciones`
- `actualizado_en`

## 4. Determinación de tarifa
La tarifa del cliente se define según:

- teléfono
- zona de entrega
- modo del caso
- condición comercial
- vigencia

### Prioridad
1. tarifa específica vigente
2. tarifa general vigente
3. revisión manual si no hay coincidencia

## 5. Flujo posterior al alta
Una vez registrado el cliente:

### Paso 1
Confirmar alta y determinar la tarifa correspondiente.

### Paso 2
Enviar **Mensaje 1**
- bienvenida
- zona
- detalle de tarifa

### Paso 3
Enviar **Mensaje 2**
- plantilla de dirección personalizada
- explicación de uso de `MAR`

## 6. Mensaje 1 — Bienvenida + tarifa
> ¡Bienvenido/a a KargasPTY!  
> Su registro ha sido realizado correctamente.  
>  
> La zona de entrega asociada a su cuenta es: **[ZONA]**.  
> La tarifa que le corresponde actualmente es: **[DETALLE TARIFA]**.  
>  
> A continuación le compartimos el formato correcto de dirección que debe colocar al momento de realizar sus compras, para que su mercancía llegue correctamente a la bodega del proveedor.

## 7. Mensaje 2 — Plantilla de dirección
> Este es el formato correcto de dirección que debe colocar al momento de realizar su compra:
>  
> **Si su carga viene por aéreo:**  
> ```text
> PC1875 [NOMBRE DEL CLIENTE]
> 6930 NW 84 AVE
> MIAMI FL 33195
> TEL 786-618-5090
> ```
>  
> **Si su carga viene por marítimo:**  
> ```text
> PC1875 MAR [NOMBRE DEL CLIENTE]
> 6930 NW 84 AVE
> MIAMI FL 33195
> TEL 786-618-5090
> ```
>  
> **Importante:**  
> - donde aparece el nombre, debe colocar **su nombre completo o el nombre de su negocio**  
> - si desea que la mercancía llegue por **marítimo**, debe incluir obligatoriamente la palabra **MAR**  
> - si no coloca **MAR**, se entenderá que la carga debe llegar por **aéreo**  
> - escriba la dirección exactamente como se le indica  
> - no cambie la dirección, ciudad, estado ni teléfono

## 8. Regla sobre el modo
El **modo** no pertenece de forma fija al cliente.  
Depende de cada compra o pedido.

Valores actuales:
- `aereo`
- `maritimo`

## 9. Regla sobre la zona
La zona base del cliente sí puede quedar registrada como:
- `zona_entrega_default`

Pero una operación puntual puede usar otra zona si el caso lo requiere.

## 10. Regla de atención
Toda respuesta al cliente debe ser:
- cortés
- clara
- sensible
- dentro del marco legal de Panamá
- enmarcada siempre dentro de lo que representa el servicio de KargasPTY

## 11. Resultado esperado
Al terminar el onboarding, el cliente debe quedar con:
- registro creado
- zona definida
- tarifa base identificada
- plantilla correcta para comprar
- instrucciones claras para que su mercancía llegue correctamente
