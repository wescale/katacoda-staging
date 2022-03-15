#!/bin/bash

show_progress()
{

  echo "Please wait until everything is ready."

  echo -n "[1/4] Recherche d'une idée..."
  sleep 0.3
  echo " Done !"

  echo -n "[2/4] Rédaction de l'article..."
  sleep 0.3
  echo " Done !"

  echo -n "[3/4] Mise en BAP..."
  sleep 0.3

  echo " BAP !"

  echo -n "[4/4] Publication..."
  sleep 0.3
  echo " You are famous ! :)"
}

show_progress