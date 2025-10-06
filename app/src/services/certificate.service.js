import { client } from '../apollo';
import { GET_CERTIFICATE, UPDATE_CERTIFICATE_LANGUAGE } from './graphql';

export const getCertificate = async (testId) => {
  try {
    const { data } = await client.query({
      query: GET_CERTIFICATE,
      variables: { testId }
    });
    return data.certificate;
  } catch (error) {
    console.error('Get certificate error:', error);
    throw error;
  }
};

export const updateCertificateLanguage = async (testId, language) => {
  try {
    const { data } = await client.mutate({
      mutation: UPDATE_CERTIFICATE_LANGUAGE,
      variables: { testId, language }
    });
    return data.updateCertificateLanguage;
  } catch (error) {
    console.error('Update certificate language error:', error);
    throw error;
  }
}; 