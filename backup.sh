#!/bin/bash
set -Eeuo pipefail
# -E fait en sorte que les fonctions et les substitutions heritent d'un trap ... ERR (pour que les erreurs soient mieux detectées)
# -e  fait en sorte que le programme s'arrete dés la premiere erreur
# -u fait en sorte qu'il y ait une erreur si une variable n\'est pas definie
# -o pipefail fait en sorte qu'un pipe echoue si l\'une de ses commandes echoue

DOSSIER="${1:-}" # premier argument ou rien s'il n\'est pas donné
DEST="${2:-./sauvegardes}"

# Vérification des arguments
if [ -z "$DOSSIER" ]; then # vrai si DOSSIER est vide -z veut dire zero length
    echo "Usage : $0 <dossier> [destination]" >&2  # affiche le format que doit suivre la commande (ce qui est entre [] est optionnel
    exit 1
fi

if [ ! -d "$DOSSIER" ]; then  # -d est vrai si le dossier existe donc cette condition est vraie s'il n\'existe pas on doit alors prevenir l\'utilisateur  
    echo "Erreur : le dossier '$DOSSIER' n'existe pas." >&2
    exit 1
fi

# Création de la destination et de l'archive horodatée
mkdir -p "$DEST"

HORODATAGE=$(date +%Y-%m-%d_%H-%M-%S)
NOM=$(basename "$DOSSIER") # basename retire tout l'arboressance du chemin absolu et grade que le nom du dossier final
ARCHIVE="$DEST/${NOM}_${HORODATAGE}.tar.gz"

tar -czf "$ARCHIVE" -C "$(dirname "$DOSSIER")" "$NOM" # créer l'archive (-c pour creer -z au format gzip -f  dans le fichier indiqué. -C permet l\'extraction dans n\'importe
# quel dossier . sinon il ne serait extractable que dans le dossier qui respecte le chemin absolu  du dossier archivé ( qui a le meme  dirname Dossier)
# dirname fait exactement l'invers de basename elle enleve le nom du dossier final et garde tout le chemin
echo "Sauvegarde créée : $ARCHIVE"

# Suppression des sauvegardes de plus de 7 jours
for fichier in "$DEST"/"${NOM}"_*.tar.gz; do # parcourir les fichier qui suivent cette expression (les fichiers archivés)
    [ -e "$fichier" ] || continue          # motif sans correspondance : on passe ( quand aucun fichier ne correspond fichier sera ecrite literalement comme l'expression
# regulière (l\'etoile sera considéré comme etant un caractere du nom du fichier -e evite d\'avoir une erreur))
    if [ -n "$(find "$fichier" -mtime +7)" ]; then # ne renvoie rien si le fichier a ete modifié il y moins de 7 jours. -n verifie justement qu'il n\'y a rien. si queleuque
#chose est renvoyé la condition sera vraie -n == not zero length 
         rm "$fichier"
        echo "Supprimé (plus de 7 jours) : $fichier"
    fi
done
