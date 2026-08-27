# Relève — planning de l'équipe infirmière

Outil collaboratif de gestion du planning annuel d'une équipe d'infirmières.
Une seule page (`index.html`), sans serveur : l'état du planning est embarqué
dans la page elle-même.

## Fonctionnalités

- **Planning sur l'année** : navigation par année (‹ ›) et par mois.
- **Chacune gère ses jours** : sélection de son identité (« Je suis »), puis
  peinture des jours au clic ou au glisser. Clic droit pour effacer.
- **7 vacations** : Matin, Soir, Nuit, Journée, Repos, Congés, Formation —
  chacune avec sa couleur, lisible en thème clair comme sombre.
- **Récapitulatifs** : par mois et par année — nombre de chaque vacation,
  jours travaillés, week-ends travaillés (pour l'équité de la répartition).
- **Jours fériés français** calculés automatiquement (fixes + Pâques,
  Ascension, Pentecôte) et signalés dans la grille.
- **Gestion d'équipe** : ajout, renommage, couleur et retrait des membres.

## Mode collaboratif

Publiée comme Artifact Claude avec la capacité `artifact`, la page
s'enregistre elle-même : le bouton **Enregistrer** publie une nouvelle version
partagée, et chaque personne ayant le lien (avec droit de modification) voit
le planning à jour. Les conflits d'enregistrement simultané sont gérés : la
page se recharge sur la version gagnante et réapplique les modifications
locales non enregistrées.

Ouverte ailleurs (par exemple via GitHub Pages), la page fonctionne en mode
local : les modifications ne sont pas partagées.

## Détails techniques

- L'état (équipe, vacations, jours) vit dans un bloc
  `<script type="application/json" id="app-state">` délimité par les
  marqueurs `<!--RELEVE-STATE-->` … `<!--/RELEVE-STATE-->`.
- À l'enregistrement, la page récupère sa propre source, remplace ce bloc et
  publie le document complet.
- Les modifications en attente sont conservées dans `sessionStorage` et
  rejouées après rechargement pour ne rien perdre.
- L'identité choisie (« Je suis ») est mémorisée par navigateur dans
  `localStorage`.
