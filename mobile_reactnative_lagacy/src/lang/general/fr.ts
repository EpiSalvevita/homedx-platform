const shared = {
  email_address: 'E-mail',
  password: 'Mot de passe'
}

const landing = {
  title: 'Le centre de dépistage digital',
  listitems: {
    1: "Il suffit d'utiliser le kit de test du commerce",
    2: 'Effectuer le test avec le smartphone',
    3: 'Obtenir un certificat qualifié',
    4: 'Paiement en ligne sécurisé'
  },
  btn: {
    login: 'Connexion',
    signup: "S'inscrire"
  }
}

const login = {
  title: 'Bienvenue!',
  subtitle:
    'Entrez votre adresse e-mail et votre mot de passe ici pour vous connecter',
  prompt__title: 'La connexion a échoué',
  prompt__subtitle:
    "Vos données d'utilisateur ne sont pas correctes. Veuillez vérifier vos coordonnées.",
  btn: {
    login: 'Connexion',
    forgot_password: 'Mot de passe oublié?'
  }
}

const signup = {
  data: {
    title: 'Vos données',
    text: 'Bienvenue sur homeDX, le centre virtuel de test rapide. Ici, vous pouvez vous inscrire pour participer. Dans la première étape, vous indiquez vos coordonnées.'
  },
  password: {
    title: 'Définir un mot de passe',
    text: 'Définissez un mot de passe sûr en utilisant un mot de passe généré aléatoirement ou saisissez vous-même un mot de passe.'
  },
  token: {
    title: 'Jetons & consentement',
    text: "Vous utilisez un jeton ? Vous pouvez l'indiquer ici. Sinon, nous avons seulement besoin de votre accord concernant nos informations sur la protection des données et les conditions générales.",
    checkbox: "Sans jeton, l'achat de licences est nécessaire.",
    hint: {
      coupon:
        "Si vous avez un coupon (code QR), vous pouvez continuer l'enregistrement sans jeton.",
      payment: "Sans jeton, l'achat de licences est nécessaire."
    }
  },
  check: {
    privacy:
      "J'accepte que homeDX GmbH traite mes données personnelles, en particulier les données relatives à ma santé, comme décrit dans les informations sur la protection des données. Je peux révoquer ce consentement à tout moment pour l'avenir *",
    tos: "J'ai lu et accepté les conditions générales de vente *"
  }
}

const availableTests = {
  1: {
    name: 'SARS-CoV-2'
  },
  1.1: {
    name: 'Test rapide',
    description: 'Testez votre infection à coronavirus'
  },
  1.2: {
    name: 'PCR-Test',
    description: 'Test PCR Corona, certificat valide inclus.'
  }
}

const nav = {
  home: 'Lancement',
  profile: 'Profil',
  certificates: 'Certificats'
}

const dashboard = {
  newest_certificate: 'Dernier certificat',
  available_tests: 'Tests disponibles'
}

const certificates = {
  title: 'Vos Certificats',
  btn_download_certificate: 'Télécharger le certificat',
  certificate_id: "No. d'attribution",
  pcr_in_progress:
    'Nous sommes en train de vérifier les données que vous avez soumises. Le statut de votre certificat PCR va changer sous peu!'
}

const fr = {
  ...shared,
  nav,
  landing,
  login,
  signup,
  dashboard,
  availableTests
}

export default fr
