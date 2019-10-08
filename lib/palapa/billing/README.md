# Billing

## Stripe Billing

On utilise le service Stripe Billing pour gérer les plans, les clients, les souscriptions et la génération et l'envoi de factures. Certaines entités sont répliquées côté Palapa pour éviter de toujours taper l'API Stripe : clients (customers), souscriptions (subscriptions) et factures (invoices).

## Période d'essai

La période d'essai est de 30 jours.

On n'utilise pas la fonctionnalité de trialing offerte par Stripe car apparemment elle commence quand même à générer des factures (de 0 eur) pendant la période d'essai (ce qu'on ne veut pas). On ne veut pas non plus avoir à demander des infos clients avant que ceux ci soient prêt à passer à un plan payant. Du coup, on gère le trial entièrement côté Palapa et on ne crée les fiches clients/souscriptions (côté Palapa + côté Stripe) qu'au moment de passer au plan payant.

Chaque compte (= 1 addresse email) ne peux avoir qu'un seul workspace d'essai. Il ne peux l'avoir qu'en créeant un nouveau compte + workspace depuis la page d'accueil. Ces workspaces ont l'attribut `allow_trial` à `true`.

## Flow de souscription

[Création client Palapa + Stripe, Création souscription Palapa + Stripe] - subscriptionController

-> [Paiement de la première facture] - PaymentController

-> [éventuellement challenge 3D Secure] -> [Mise à jour CB si 3DSecure échoue] - PaymentController + StripeJS)

-> Mise à jour souscription côté Palapa depuis les données Stripe. - subscription/refresh

-> Un webhook lancé côté Stripe s'assure en plus que les changements de statut dans les souscriptions seront bien poussés sur Palapa. - /stripe_webhooks

## Droits d'accès

Seuls les Owners d'un workspace peuvent mettre à jour les infos de paiements et payer.

## Paiements avec 3DSecure

3DSecure est activé dynamiquement en fonction des CB, des banques, etc. Il faut faire une tentative de paiement (PaymentIntent) et voir si ca passe ou s'il y a une `action_required` en retour. Si une action est requise, on laisse StripeJS se charger d'afficher le challenge 3DSecure. Si le challenge échoue on demande au client de mettre à jour sa CB.

On effectue le paiement avec l'option `setup_future_usage: "off_session"` pour permettre les mois suivants de débiter la carte sans avoir besoin que le client soit connecté et qu'il ait besoin de refaire un challenge 3DSecure.
