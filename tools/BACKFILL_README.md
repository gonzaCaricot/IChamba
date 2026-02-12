# Backfill Users from Auth

Esta carpeta contiene herramientas para sincronizar usuarios de `auth.users` hacia la tabla `public.users`.

## ¿Por qué es necesario?

La app almacena usuarios en dos lugares:
- **auth.users**: Tabla automática de Supabase Auth (contiene todas las cuentas autenticadas)
- **public.users**: Tabla personalizada donde se almacenan perfiles, roles, etc.

Cuando nuevas cuentas se crean via Auth, no tienen automáticamente una fila en `public.users`. 
Esto hace que no aparezcan en el selector de "Nuevo mensaje".

## Solución 1: Ejecutar SQL en Supabase (Recomendado)

### Pasos:

1. Abre [Supabase Dashboard](https://app.supabase.com)
2. Ve a tu proyecto IChamba
3. Abre **SQL Editor** (en el sidebar)
4. Haz clic en **New Query**
5. Abre el archivo `tools/backfill_users.sql` en tu editor
6. Copia TODO el contenido
7. Pégalo en el SQL Editor de Supabase
8. Haz clic en **Run**
9. Verifica los resultados en las consultas `SELECT` al final

### ¿Qué hace?

- Inserta filas en `public.users` para cada usuario de `auth.users` que no tenga fila aún
- Usa `ON CONFLICT (auth_id) DO NOTHING` para no duplicar si ya existe
- Extrae `first_name` y `last_name` de los metadatos del usuario (si existen)
- Asigna rol por defecto `'usuario'` a nuevas cuentas

### Resultado esperado:

```
INSERT 0 5
INSERT 0 1
(Números indican cuántas filas se insertaron)
```

Luego verás un listado de todos los usuarios en `public.users`.

---

## Solución 2: Script Dart (Alternativa)

Si prefieres ejecutar desde código:

```bash
# Asegúrate de estar en la raíz del proyecto
cd c:\Users\gonza\IChamba

# Ejecuta el script
dart run tools/backfill_users.dart
```

**Nota:** Este script intentará conectarse a Supabase, pero probablemente falle por seguridad RLS 
(necesitaría la SERVICE_ROLE_KEY). Aun así, te dará instrucciones claras.

---

## Verificación Posterior

Después de ejecutar el backfill:

1. Abre la app
2. Inicia sesión
3. Ve a **Mensajes**
4. Haz clic en el botón **componer** (edit_square icon)
5. Deberías ver otros usuarios en la lista

Si aún ves "No hay otros usuarios registrados":
- Verifica en Supabase que `public.users` tiene más de 1 fila
- Recarga la app completamente (reinicia)
- Revisa los logs de Flutter (observa los `[fetchOtherUsers]` debugPrint)

---

## Automatización Futura

La app ahora intenta sincronizar automáticamente después del login:
- `SupabaseService.syncUsersFromAuth()` se llama tras login exitoso
- Si falla por RLS, la app continúa normalmente
- Los usuarios existentes en `public.users` se mostrarán en el picker

---

## Problemas Comunes

**P: Ejecuté el SQL pero aún no veo usuarios**

R: 
1. Verifica que el SQL se ejecutó sin errores (check la respuesta de Supabase)
2. Asegúrate de refrescar la app completamente
3. Revisa que los emails en `auth.users` sean válidos

**P: El script Dart no funciona**

R: Usa la Solución 1 (SQL directo). El script requiere permisos especiales que la app no tiene por seguridad.

**P: ¿Perderé datos si ejecuto el backfill?**

R: No. El SQL usa `ON CONFLICT (auth_id) DO NOTHING`, así que solo inserta filas nuevas.

---

## Contacto

Si tienes problemas:
1. Revisa los logs de `[fetchOtherUsers]` en Flutter console
2. Verifica tablas en Supabase → Table Editor
3. Consulta el archivo `tools/backfill_users.sql` para ver exactamente qué hace
