import React from 'react';
import { useQuery } from '@apollo/client';
import { useTranslation } from 'react-i18next';
import { GET_IMPRESSUM } from '../services/graphql';
import LoadingView from '../components/LoadingView';
import ContentHeader from '../components/ContentHeader';

export default function Impressum() {
  const { i18n } = useTranslation();
  const currentLanguage = i18n.language || 'de';
  
  // Normalize language code (en-US -> en, de-DE -> de, etc.)
  const normalizedLanguage = currentLanguage.split('-')[0];
  
  const { loading, error, data } = useQuery(GET_IMPRESSUM, {
    variables: { language: normalizedLanguage },
    errorPolicy: 'all'
  });

  if (loading) {
    return <LoadingView />;
  }

  if (error || !data?.getImpressum) {
    const errorMessages = {
      de: {
        title: "Impressum",
        error: "Entschuldigung, das Impressum konnte nicht geladen werden.",
        retry: "Bitte versuchen Sie es später erneut."
      },
      en: {
        title: "Legal Notice",
        error: "Sorry, the legal notice could not be loaded.",
        retry: "Please try again later."
      },
      fr: {
        title: "Mentions Légales",
        error: "Désolé, les mentions légales n'ont pas pu être chargées.",
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

  const impressum = data.getImpressum;

  return (
    <div className="content-page">
      <ContentHeader title={impressum.title} showTitle={true} />
      <div className="content-body">
        <div className="legal-content">
          {impressum.content.split('\n\n').map((paragraph, index) => {
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
            {normalizedLanguage === 'de' && `Version ${impressum.version} - Zuletzt aktualisiert: ${new Date(impressum.updatedAt).toLocaleDateString('de-DE')}`}
            {normalizedLanguage === 'en' && `Version ${impressum.version} - Last updated: ${new Date(impressum.updatedAt).toLocaleDateString('en-US')}`}
            {normalizedLanguage === 'fr' && `Version ${impressum.version} - Dernière mise à jour: ${new Date(impressum.updatedAt).toLocaleDateString('fr-FR')}`}
          </p>
        </div>
      </div>
    </div>
  );
} 