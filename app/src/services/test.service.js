import { client } from '../apollo';
import {
  GET_TEST_STATUS,
  START_NEW_TEST,
  UPLOAD_TEST_PHOTO
} from './graphql';

export const getTestStatus = async () => {
  try {
    const { data } = await client.query({
      query: GET_TEST_STATUS
    });
    return data.testStatus;
  } catch (error) {
    console.error('Get test status error:', error);
    throw error;
  }
};

export const startNewTest = async (input) => {
  try {
    const { data } = await client.mutate({
      mutation: START_NEW_TEST,
      variables: { input }
    });
    return data.startTest;
  } catch (error) {
    console.error('Start new test error:', error);
    throw error;
  }
};

export const uploadTestPhoto = async (file, testId) => {
  try {
    const { data } = await client.mutate({
      mutation: UPLOAD_TEST_PHOTO,
      variables: { file, testId }
    });
    return data.uploadTestPhoto;
  } catch (error) {
    console.error('Upload test photo error:', error);
    throw error;
  }
}; 