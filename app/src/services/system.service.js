import { client } from '../apollo';
import { GET_BACKEND_STATUS } from './graphql';

export const getBackendStatus = async () => {
  try {
    const { data } = await client.query({
      query: GET_BACKEND_STATUS
    });
    return data.backendStatus;
  } catch (error) {
    console.error('Get backend status error:', error);
    throw error;
  }
}; 