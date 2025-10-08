#!/usr/bin/env bash
set -euo pipefail

# Nombre del Service (LoadBalancer) que quieres golpear
LB_HOST="http://nginx-lb"

# Label selector para tus pods nginx
LABEL_SELECTOR="app=nginx-demo"

echo "Buscando pods con selector: $LABEL_SELECTOR ..."
PODS=$(kubectl get pods -l ${LABEL_SELECTOR} -o jsonpath='{.items[*].metadata.name}')

if [ -z "$PODS" ]; then
  echo "No se encontraron pods con selector ${LABEL_SELECTOR}. Salida."
  exit 1
fi

echo "Pods encontrados: $PODS"
echo

for POD in $PODS; do
  echo "----- POD: $POD -----"

  # 1) comprobar si wget existe en el pod
  HAS_WGET=$(kubectl exec "$POD" -- sh -c 'command -v wget >/dev/null 2>&1 && echo yes || echo no' 2>/dev/null || echo no)
  HAS_CURL=$(kubectl exec "$POD" -- sh -c 'command -v curl >/dev/null 2>&1 && echo yes || echo no' 2>/dev/null || echo no)

  if [ "$HAS_WGET" = "yes" ] || [ "$HAS_CURL" = "yes" ]; then
    echo "-> Encontrado $( [ "$HAS_WGET" = "yes" ] && echo wget || echo curl ) en $POD. Iniciando loop dentro del Pod (en background)."

    # Ejecutar loop en background dentro del Pod (no -it). Usamos paréntesis para background.
    if [ "$HAS_WGET" = "yes" ]; then
      kubectl exec "$POD" -- sh -c "(while true; do wget -q -O- ${LB_HOST} >/dev/null 2>&1; done) &" || echo "Aviso: fallo al lanzar loop en $POD"
    else
      kubectl exec "$POD" -- sh -c "(while true; do curl -s ${LB_HOST} >/dev/null 2>&1; done) &" || echo "Aviso: fallo al lanzar loop en $POD"
    fi

    echo "  Loop arrancado en $POD (fondo)."
  else
    # 2) Si wget/curl no existe: crear pod busybox temporal que cible la IP del Pod nginx
    POD_IP=$(kubectl get pod "$POD" -o jsonpath='{.status.podIP}')
    if [ -z "$POD_IP" ]; then
      echo "  No se pudo obtener IP de $POD, se saltará."
      continue
    fi

    GEN_POD="load-to-${POD}"
    echo "-> wget/curl NO encontrado en $POD. Crear pod temporal $GEN_POD que hará peticiones a http://${POD_IP}:80 (en background)."

    # Creamos un pod busybox que ejecuta el loop y no se reinicia (--restart=Never).
    # Lo lanzamos de forma que el proceso quede corriendo; kubectl run retorna cuando el pod está creado.
    kubectl run "$GEN_POD" --image=busybox --restart=Never -- sh -c "while true; do wget -q -O- http://${POD_IP}:80 >/dev/null 2>&1; done" >/dev/null 2>&1 || echo "  Aviso: fallo al crear pod $GEN_POD"
    echo "  Pod temporal $GEN_POD creado y ejecutando."
    echo "  (Para ver logs: kubectl logs -f $GEN_POD )"
  fi

  echo
done

echo "He intentado arrancar loops en todos los pods encontrados."
echo
echo "Cómo detener los loops:"
echo " - Para detener loops lanzados DENTRO de pods (si wget/curl existía):"
echo "     kubectl exec <pod> -- pkill -f wget || true"
echo "     kubectl exec <pod> -- pkill -f curl || true"
echo
echo " - Para eliminar los pods temporales busybox creados (si los hubo):"
echo "     kubectl delete pod -l run=load-to- -n default --ignore-not-found"
echo
echo " (También puedes listar pods creados con prefijo 'load-to-' y borrarlos manualmente.)"
