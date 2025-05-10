#!/bin/bash

# Terminal Hero - Quizz interactif sur les commandes Unix
# Équipe : Ahmadou, Adamou Mahamane, Rabiou Mahamane, Sani Dan Salaou, Mamoudou Souley

# Date : 10-11 Mai 2025

# Fichiers utilisés
QUESTIONS_FILE="questions.txt"
SCORES_FILE="scores.txt"

# Initialisation des variables
SCORE=0
TOTAL_QUESTIONS=0
PLAYER_NAME=""

# Fonction pour afficher un message coloré
print_colored() {
    local color=$1
    local message=$2
    tput setaf $color
    echo "$message"
    tput sgr0
}

# Fonction pour vérifier si le fichier des questions existe
check_questions_file() {
    if [ ! -f "$QUESTIONS_FILE" ]; then
        print_colored 1 "Erreur : Le fichier $QUESTIONS_FILE n'existe pas."
        exit 1
    fi
}

# Fonction pour lire une question aléatoire
get_random_question() {
    check_questions_file
    local total_lines=$(wc -l < "$QUESTIONS_FILE")
    if [ "$total_lines" -eq 0 ]; then
        print_colored 1 "Erreur : Aucune question disponible dans $QUESTIONS_FILE."
        exit 1
    fi
    local random_line=$((RANDOM % total_lines + 1))
    sed -n "${random_line}p" "$QUESTIONS_FILE"
}

# Fonction pour valider une entrée numérique
validate_numeric_input() {
    local input=$1
    local range=$2
    if [[ ! $input =~ ^[0-9]+$ ]] || [ "$input" -lt 1 ] || [ "$input" -gt "$range" ]; then
        print_colored 1 "Erreur : Veuillez entrer un numéro entre 1 et $range."
        return 1
    fi
    return 0
}

# Fonction pour jouer une partie
play_game() {
    SCORE=0
    TOTAL_QUESTIONS=0
    print_colored 6 "Bienvenue dans le quizz Terminal Hero, $PLAYER_NAME !"
    while true; do
        # Lire une question (format : Question|Choix1|Choix2|Choix3|Choix4|Réponse)
        IFS='|' read -r question c1 c2 c3 c4 correct_answer < <(get_random_question)
        ((TOTAL_QUESTIONS++))

        # Afficher la question et les choix
        echo -e "\n$question"
        echo "1) $c1"
        echo "2) $c2"
        echo "3) $c3"
        echo "4) $c4"

        # Demander une réponse
        read -p "Votre réponse (1-4) : " answer
        if ! validate_numeric_input "$answer" 4; then
            continue
        fi

        # Vérifier la réponse
        if [ "$answer" = "$correct_answer" ]; then
            print_colored 2 "Correct ! +10 points"
            ((SCORE+=10))
        else
            print_colored 1 "Incorrect. La réponse était : $correct_answer"
        fi

        # Afficher le score
        echo "Score actuel : $SCORE"

        # Continuer ou quitter
        read -p "Continuer ? (o/n) : " continue
        if [ "$continue" != "o" ]; then
            break
        fi
    done

    # Sauvegarder le score
    echo "$(date '+%Y-%m-%d %H:%M:%S')|$PLAYER_NAME|$SCORE|$TOTAL_QUESTIONS" >> "$SCORES_FILE"
    print_colored 6 "Fin du jeu ! Score final : $SCORE sur $TOTAL_QUESTIONS questions."
}

# Fonction pour ajouter une question
add_question() {
    print_colored 6 "Ajout d'une nouvelle question"
    read -p "Entrez la question : " question
    read -p "Entrez le choix 1 : " c1
    read -p "Entrez le choix 2 : " c2
    read -p "Entrez le choix 3 : " c3
    read -p "Entrez le choix 4 : " c4
    read -p "Entrez le numéro de la réponse correcte (1-4) : " correct_answer
    if ! validate_numeric_input "$correct_answer" 4; then
        return
    fi
    # Ajouter la question au fichier
    echo "$question|$c1|$c2|$c3|$c4|$correct_answer" >> "$QUESTIONS_FILE"
    print_colored 2 "Question ajoutée avec succès !"
}

# Fonction pour supprimer une question
delete_question() {
    check_questions_file
    print_colored 6 "Liste des questions :"
    nl -s ") " "$QUESTIONS_FILE" | cut -d'|' -f1
    local total_lines=$(wc -l < "$QUESTIONS_FILE")
    read -p "Entrez le numéro de la question à supprimer (1-$total_lines) : " line_number
    if ! validate_numeric_input "$line_number" "$total_lines"; then
        return
    fi
    # Supprimer la ligne
    sed -i "${line_number}d" "$QUESTIONS_FILE"
    print_colored 2 "Question supprimée avec succès !"
}

# Fonction pour afficher les scores
view_scores() {
    if [ ! -f "$SCORES_FILE" ]; then
        print_colored 1 "Aucun score enregistré."
        return
    fi
    print_colored 6 "Historique des scores :"
    echo "Date | Joueur | Score | Questions"
    while IFS='|' read -r date player score questions; do
        echo "$date | $player | $score | $questions"
    done < "$SCORES_FILE"
}

# Menu principal
clear
print_colored 6 "=== Terminal Hero ==="
read -p "Entrez votre nom : " PLAYER_NAME
while true; do
    echo -e "\nMenu :"
    echo "1) Jouer au quizz"
    echo "2) Ajouter une question"
    echo "3) Supprimer une question"
    echo "4) Voir les scores"
    echo "5) Quitter"
    read -p "Choisissez une option (1-5) : " choice
    case $choice in
        1) play_game ;;
        2) add_question ;;
        3) delete_question ;;
        4) view_scores ;;
        5) print_colored 6 "Merci d’avoir joué à Terminal Hero !"; exit 0 ;;
        *) print_colored 1 "Option invalide. Choisissez un numéro entre 1 et 5." ;;
    esac
done