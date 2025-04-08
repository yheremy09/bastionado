# Ejecutar el comando para obtener la lista de usuarios que pueden crear pods
USERS=$(oc adm policy who-can create pod)

# Contar cuántos usuarios pueden crear pods
USER_COUNT=$(echo "$USERS" | grep -c 'user')

# Imprimir el resultado
echo "Número de usuarios que pueden crear pods: $USER_COUNT"
exit 2
