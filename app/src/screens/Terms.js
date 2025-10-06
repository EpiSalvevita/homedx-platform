import React from 'react';
import { useQuery } from '@apollo/client';
import { useTranslation } from 'react-i18next';
import { GET_TERMS_AND_CONDITIONS } from '../services/graphql';
import LoadingView from '../components/LoadingView';
import ContentHeader from '../components/ContentHeader';

export default function Terms() {
  const { i18n } = useTranslation();
  const currentLanguage = i18n.language || 'de';
  
  // Normalize language code (en-US -> en, de-DE -> de, etc.)
  const normalizedLanguage = currentLanguage.split('-')[0];
  
  const { loading, error, data } = useQuery(GET_TERMS_AND_CONDITIONS, {
    variables: { language: normalizedLanguage },
    errorPolicy: 'all'
  });

  if (loading) {
    return <LoadingView />;
  }

  if (error || !data?.getTermsAndConditions) {
    const errorMessages = {
      de: {
        title: "Allgemeine Geschäftsbedingungen",
        error: "Entschuldigung, die Allgemeinen Geschäftsbedingungen konnten nicht geladen werden.",
        retry: "Bitte versuchen Sie es später erneut."
      },
      en: {
        title: "Terms and Conditions",
        error: "Sorry, the terms and conditions could not be loaded.",
        retry: "Please try again later."
      },
      fr: {
        title: "Conditions Générales",
        error: "Désolé, les conditions générales n'ont pas pu être chargées.",
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

  const termsAndConditions = data.getTermsAndConditions;

  return (
    <div className="content-page">
      <ContentHeader title={termsAndConditions.title} showTitle={true} />
      <div className="content-body">
        <div className="legal-content">
          {termsAndConditions.content.split('\n\n').map((paragraph, index) => {
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
            {normalizedLanguage === 'de' && `Version ${termsAndConditions.version} - Zuletzt aktualisiert: ${new Date(termsAndConditions.updatedAt).toLocaleDateString('de-DE')}`}
            {normalizedLanguage === 'en' && `Version ${termsAndConditions.version} - Last updated: ${new Date(termsAndConditions.updatedAt).toLocaleDateString('en-US')}`}
            {normalizedLanguage === 'fr' && `Version ${termsAndConditions.version} - Dernière mise à jour: ${new Date(termsAndConditions.updatedAt).toLocaleDateString('fr-FR')}`}
          </p>
        </div>
      </div>
    </div>
  );
} 