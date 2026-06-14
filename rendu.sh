#!/bin/bash

set -e

RAPPORT_SRC="rapport.pdf"
ARCHIVE_SRC="sources.tar.gz"
RENDU="rendu.zip"

echo "Nettoyage des anciennes archives..."
rm -f "$RENDU" "$ARCHIVE_SRC"

echo "Vérification du rapport..."
if [ ! -f "$RAPPORT_SRC" ]; then
    echo "Erreur : $RAPPORT_SRC introuvable."
    exit 1
fi

echo "Vérification des dossiers sources..."
for dir in src src_cpld src_pr src_tb; do
    if [ ! -d "$dir" ]; then
        echo "Erreur : dossier $dir introuvable."
        exit 1
    fi
done

echo "Création de l'archive des sources..."
tar --exclude='comp' \
    --exclude='pr' \
    --exclude='pr_cpld' \
    -czf "$ARCHIVE_SRC" \
    src src_cpld src_pr src_tb *.tcl

echo "Création de $RENDU..."
zip "$RENDU" "$RAPPORT_SRC" "$ARCHIVE_SRC"

echo "Archive créée avec succès : $RENDU"
echo "Contenu :"
unzip -l "$RENDU"