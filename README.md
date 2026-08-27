# Relève — planning de l'équipe infirmière

Outil collaboratif de gestion du planning annuel d'une équipe d'infirmières.
Une seule page (`index.html`), sans serveur : l'état du planning est embarqué
dans la page elle-même.

## Fonctionnalités

- **Trois vues** de période (année, mois, semaine) combinées à un sélecteur
  **Tous / par infirmière**, avec navigation ‹ › et bouton « Aujourd'hui ».
- **Chacune gère ses jours** : on choisit son prénom dans « Afficher », puis
  on saisit ses jours au clic ou au glisser. Clic droit pour effacer.
- **4 statuts** : Travail, Repos, Rempla à trouver, Rempla booké. « Rempla à
  trouver » est cerclé d'orange pour repérer les trous à combler.
- **Récapitulatifs** : sur la période affichée et sur l'année — nombre de jours
  par statut et week-ends travaillés (pour l'équité de la répartition).
- **Jours fériés français** calculés automatiquement (fixes + Pâques,
  Ascension, Pentecôte) et signalés dans la grille.
- **Gestion d'équipe** : ajout, renommage, couleur et retrait des membres.
- **Remplaçants** : carnet d'adresses, récapitulatif des jours à pourvoir et
  envoi de la demande sur WhatsApp.

## Vues et sélecteur d'affichage

Trois onglets de période — **Année**, **Mois**, **Semaine** — et une ligne
« Afficher » qui choisit *qui* est montré : **Tous** (vue globale) ou une
infirmière en particulier.

| Afficher | Année | Mois | Semaine |
| --- | --- | --- | --- |
| **Tous** (vue globale, lecture seule) | 12 calendriers, chaque jour segmenté aux couleurs des personnes au travail | Calendrier du mois : chaque jour ne montre que **qui travaille**, à sa couleur (sur téléphone, un jour par ligne) | Les 7 jours et qui travaille |
| **Une infirmière** | 12 calendriers, un trait de couleur par jour selon son statut | Calendrier du mois, statuts écrits en clair | Les 7 jours, son statut |

En vue globale les repos ne sont pas affichés : seules apparaissent les
personnes au travail, les postes qu'une infirmière a signalés à remplacer, et
la couverture du jour (rempla à trouver / booké). La saisie se fait en
choisissant une infirmière, ou depuis le panneau « Jours sans personne ».

## Jours sans personne et remplaçants

- **Jours sans personne** liste, sur la période affichée, les journées où
  aucune infirmière n'est au travail. Pour chacune : deux boutons **À trouver**
  / **Booké** et un menu pour **assigner un remplaçant**.
- **Remplaçants** est le carnet d'adresses : prénom et téléphone de chaque
  remplaçant.
- **Partager sur WhatsApp** compose un message listant les jours encore à
  pourvoir et ouvre WhatsApp — soit sur le contact choisi (bouton WhatsApp en
  face d'un remplaçant), soit sans destinataire pour le choisir dans WhatsApp.
  Les numéros français (`06…`) sont convertis au format international.

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

En dessous de 760 px, la vue année passe à deux calendriers par ligne et la vue
globale du mois bascule en liste (un jour par ligne), ce qui supprime tout
défilement horizontal. L'en-tête de page reste collé en haut, la barre des mois
et les puces de statut défilent horizontalement, et les cibles tactiles font
au moins 42 px. On saisit au **tap** (et non au contact) pour qu'un simple
défilement ne marque jamais un jour par erreur.

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
- L'état (équipe, statuts des jours, remplaçants, couverture) vit dans un bloc
  `<script type="application/json" id="app-state">` délimité par les
  marqueurs `<!--RELEVE-STATE-->` … `<!--/RELEVE-STATE-->`.
- À l'enregistrement, la page récupère sa propre source, remplace ce bloc et
  publie le document complet.
- Les modifications en attente sont conservées dans `sessionStorage` et
  rejouées après rechargement pour ne rien perdre.
- La personne affichée et le repère « C'est moi » (panneau « Gérer l'équipe »)
  sont mémorisés par navigateur dans `localStorage`.
- Les remplaçants (`subs`) et la couverture des jours (`cover`) font partie de
  l'état partagé.
