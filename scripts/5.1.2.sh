# Ejecutar el comando para obtener la lista de usuarios que pueden crear pods
USERS=$(oc adm policy who-can get secrets)

# Contar cuántos usuarios pueden crear pods
USER_COUNT=$(echo "$USERS" | grep -c 'user')

# Imprimir el resultado
echo "Número de usuarios que pueden get secrets: $USER_COUNT"

USERS=$(oc adm policy who-can list secrets)

# Contar cuántos usuarios pueden crear pods
USER_COUNT=$(echo "$USERS" | grep -c 'user')

# Imprimir el resultado
echo "Número de usuarios que pueden list secrets: $USER_COUNT"

USERS=$(oc adm policy who-can watch secrets)

# Contar cuántos usuarios pueden crear pods
USER_COUNT=$(echo "$USERS" | grep -c 'user')

# Imprimir el resultado
echo "Número de usuarios que pueden watch secrets: $USER_COUNT"

exit 2
