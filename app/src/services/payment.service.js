import { client } from '../apollo';
import { CREATE_PAYMENT } from './graphql';

export const createPayment = async (input) => {
  try {
    const { data } = await client.mutate({
      mutation: CREATE_PAYMENT,
      variables: { input }
    });
    return data.createPayment;
  } catch (error) {
    console.error('Create payment error:', error);
    throw error;
  }
}; 