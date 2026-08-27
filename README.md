# Relève — planning de l'équipe infirmière

Outil collaboratif de gestion du planning annuel d'une équipe d'infirmières.
Une seule page (`index.html`), sans serveur : l'état du planning est embarqué
dans la page elle-même.

## Fonctionnalités

- **Quatre vues** commutables : **général**, **année**, **mois** et
  **semaine**, avec une navigation ‹ › adaptée à la période et un bouton
  « Aujourd'hui ».
- **Chacune gère ses jours** : sélection de son identité (« Je suis »), puis
  saisie des jours au clic ou au glisser. Clic droit pour effacer.
- **4 statuts** : Travail, Repos, Rempla à trouver, Rempla booké. « Rempla à
  trouver » est cerclé d'orange pour repérer les trous à combler.
- **Récapitulatifs** : sur la période affichée et sur l'année — nombre de jours
  par statut et week-ends travaillés (pour l'équité de la répartition).
- **Jours fériés français** calculés automatiquement (fixes + Pâques,
  Ascension, Pentecôte) et signalés dans la grille.
- **Gestion d'équipe** : ajout, renommage, couleur et retrait des membres.

## Les quatre vues

| Vue | Contenu | Navigation ‹ › |
| --- | --- | --- |
| **Général** | Toute l'équipe mélangée dans un calendrier mensuel : chaque journée liste les infirmières avec leur statut. Sur téléphone, jours en lignes et infirmières en colonnes. | Mois |
| **Année** | Une infirmière à la fois, 12 calendriers mensuels (lundi → dimanche) avec un trait de couleur sous chaque jour. Cliquer un nom de mois l'ouvre en vue mois. | Année |
| **Mois** | Une infirmière à la fois, même calendrier que la vue année mais sur un seul mois, statuts écrits en clair (abrégés sur téléphone). | Mois |
| **Semaine** | Toute l'équipe, les 7 jours en toutes lettres, statuts écrits en clair. | Semaine |

Les vues **Année** et **Mois** portent une barre « Planning de » pour choisir
l'infirmière affichée ; les vues **Général** et **Semaine** montrent toute
l'équipe.

La vue choisie est mémorisée par navigateur. Les flèches ← → du clavier
changent aussi de période.

## Application mobile (installable sur iPhone)

La page est une *web app* installable : elle s'adapte au téléphone et peut être
ajoutée à l'écran d'accueil.

- **Sur iPhone** : ouvrir le site dans Safari, toucher **Partager** puis
  **« Sur l'écran d'accueil »**. Un rappel s'affiche en bas de la page tant que
  ce n'est pas fait (il peut être masqué).
- **Sur Android** : Chrome propose « Installer l'application ».

Une fois installée, l'application s'ouvre en plein écran, sans barre d'adresse,
avec sa propre icône.

### Ce qui change sur petit écran

En dessous de 760 px, la grille bascule : les **jours deviennent les lignes** et
les **infirmières les colonnes**, ce qui supprime tout défilement horizontal.
L'en-tête de page et celui du tableau restent collés en haut, la barre des mois
et les puces de statut défilent horizontalement, et les cibles tactiles font
au moins 42 px. La vue année passe à deux calendriers par ligne et la vue
Général bascule en liste (jours en lignes). On peint au **tap** (et non au
contact) pour qu'un simple défilement ne marque jamais un jour par erreur.

Le service worker (`sw.js`) garde la page ouvrable hors connexion ; les données
du planning passent toujours par le réseau, jamais par le cache.

## Roulement pré-rempli 2027

L'année 2027 est pré-remplie avec un roulement de deux semaines entre deux
personnes, qui couvre tous les jours de l'année :

| Semaine | Personne en semaine A | Personne en semaine B |
| --- | --- | --- |
| A | lundi, mardi, vendredi, samedi, dimanche | mercredi, jeudi |

Les deux s'échangent les rôles chaque semaine. Axelle démarre en semaine A,
ce qui la place au travail le vendredi 1er janvier 2027 ; sur l'année cela
donne 183 jours travaillés pour elle et 182 pour sa collègue, avec exactement
une infirmière présente chaque jour.

Le roulement est appliqué une seule fois (marqueur `seeds` dans l'état
partagé), puis chacune reste libre de modifier ses jours ; il ne se
réapplique jamais par-dessus les modifications de l'équipe.

Les plannings créés avec l'ancien jeu de vacations (Matin, Soir, Nuit,
Journée, Formation, Congés) sont convertis automatiquement et une seule fois
vers les quatre statuts : tout ce qui était travaillé devient **Travail**, les
congés deviennent **Repos** (marqueur `statuts-v2`).

## Mode collaboratif

Deux hébergements possibles, avec synchronisation d'équipe dans les deux cas :

### 1. GitHub Pages + Supabase (hébergement de référence)

Le dépôt contient un workflow (`.github/workflows/pages.yml`) qui déploie la
page sur GitHub Pages à chaque push. La synchronisation passe par une petite
base Supabase (gratuite) :

1. Créer un projet sur [supabase.com](https://supabase.com) (gratuit).
2. Dans **SQL Editor**, exécuter le contenu de `supabase.sql`.
3. Dans **Project Settings → API**, copier la *Project URL* et la clé
   *anon public*.
4. Les renseigner dans `config.js` (décommenter le bloc), puis pousser.

L'enregistrement est alors automatique (2,5 s après la dernière modification),
les autres navigateurs se rafraîchissent toutes les 30 s et au retour sur
l'onglet, et les enregistrements simultanés sont fusionnés (version du serveur
reprise, modifications locales rejouées par-dessus, nouvel essai).

La clé *anon public* est faite pour être publiée ; l'accès aux données est
régi par les politiques RLS de `supabase.sql` (toute personne ayant le lien
peut lire et modifier — même modèle de confiance qu'un tableur partagé).

### 2. Artifact claude.ai

Publiée comme Artifact avec la capacité `artifact`, la page s'enregistre
elle-même : le bouton **Enregistrer** publie une nouvelle version partagée
pour toutes les personnes ayant reçu le lien avec droit de modification.
En cas d'enregistrements simultanés, la page se recharge sur la version
gagnante et réapplique les modifications locales non enregistrées.

Sans Supabase configuré ni capacité artifact (par exemple fichier ouvert en
local), la page fonctionne en mode local : les modifications ne sont pas
partagées.

## Détails techniques

- `index.html` est un document HTML complet (déployé tel quel sur GitHub Pages).
- L'état (équipe, vacations, jours) vit dans un bloc
  `<script type="application/json" id="app-state">` délimité par les
  marqueurs `<!--RELEVE-STATE-->` … `<!--/RELEVE-STATE-->`.
- À l'enregistrement, la page récupère sa propre source, remplace ce bloc et
  publie le document complet.
- Les modifications en attente sont conservées dans `sessionStorage` et
  rejouées après rechargement pour ne rien perdre.
- L'identité choisie (« Je suis ») est mémorisée par navigateur dans
  `localStorage`.
