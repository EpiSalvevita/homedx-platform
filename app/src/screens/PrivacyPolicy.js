import React from 'react';
import { useQuery } from '@apollo/client';
import { useTranslation } from 'react-i18next';
import { GET_PRIVACY_POLICY } from '../services/graphql';
import LoadingView from '../components/LoadingView';
import ContentHeader from '../components/ContentHeader';

export default function PrivacyPolicy() {
  const { i18n } = useTranslation();
  const currentLanguage = i18n.language || 'de';
  
  // Normalize language code (en-US -> en, de-DE -> de, etc.)
  const normalizedLanguage = currentLanguage.split('-')[0];
  
  const { loading, error, data } = useQuery(GET_PRIVACY_POLICY, {
    variables: { language: normalizedLanguage },
    errorPolicy: 'all'
  });

  if (loading) {
    return <LoadingView />;
  }

  if (error || !data?.getPrivacyPolicy) {
    const errorMessages = {
      de: {
        title: "Datenschutzerklärung",
        error: "Entschuldigung, die Datenschutzerklärung konnte nicht geladen werden.",
        retry: "Bitte versuchen Sie es später erneut."
      },
      en: {
        title: "Privacy Policy",
        error: "Sorry, the privacy policy could not be loaded.",
        retry: "Please try again later."
      },
      fr: {
        title: "Politique de Confidentialité",
        error: "Désolé, la politique de confidentialité n'a pas pu être chargée.",
        retry: "Veuillez réessayer plus tard."
      }
    };
    
    const messages = errorMessages[normalizedLanguage] || errorMessages.en;
    
    return (
      <div className="content-page">
        <ContentHeader title={messages.title} showTitle={true} />
        <div className="content-body">
          <div className="error-message">
            <p>{messages.error}</p>
            <p>{messages.retry}</p>
          </div>
        </div>
      </div>
    );
  }

  const privacyPolicy = data.getPrivacyPolicy;

  return (
    <div className="content-page">
      <ContentHeader title={privacyPolicy.title} showTitle={true} />
      <div className="content-body">
        <div className="legal-content">
          {privacyPolicy.content.split('\n\n').map((paragraph, index) => {
            // Handle headings (lines that don't end with punctuation and are shorter)
            if (paragraph.length < 100 && !paragraph.match(/[.!?]$/)) {
              return (
                <h3 key={index} className="legal-heading">
                  {paragraph}
                </h3>
              );
            }
            
            // Handle regular paragraphs
            return (
              <p key={index} className="legal-paragraph">
                {paragraph}
              </p>
            );
          })}
        </div>
        
        <div className="legal-footer">
          <p className="legal-version">
            {normalizedLanguage === 'de' && `Version ${privacyPolicy.version} - Zuletzt aktualisiert: ${new Date(privacyPolicy.updatedAt).toLocaleDateString('de-DE')}`}
            {normalizedLanguage === 'en' && `Version ${privacyPolicy.version} - Last updated: ${new Date(privacyPolicy.updatedAt).toLocaleDateString('en-US')}`}
            {normalizedLanguage === 'fr' && `Version ${privacyPolicy.version} - Dernière mise à jour: ${new Date(privacyPolicy.updatedAt).toLocaleDateString('fr-FR')}`}
          </p>
        </div>
      </div>
    </div>
  );
} 