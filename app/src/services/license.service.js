import { client } from '../apollo';
import { GET_LICENSES, ACTIVATE_LICENSE } from './graphql';

export const getLicenses = async () => {
  try {
    const { data } = await client.query({
      query: GET_LICENSES
    });
    return data.licenses;
  } catch (error) {
    console.error('Get licenses error:', error);
    throw error;
  }
};

export const activateLicense = async (code) => {
  try {
    const { data } = await client.mutate({
      mutation: ACTIVATE_LICENSE,
      variables: { code }
    });
    return data.activateLicense;
  } catch (error) {
    console.error('Activate license error:', error);
    throw error;
  }
}; 