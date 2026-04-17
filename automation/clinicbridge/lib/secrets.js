require('dotenv').config();

function resolveSecret(credentialRef) {
  const raw = process.env.CREDENTIAL_SECRET_MAP || '{}';
  let map;

  try {
    map = JSON.parse(raw);
  } catch (error) {
    throw new Error('CREDENTIAL_SECRET_MAP is not valid JSON');
  }

  const value = map[credentialRef];

  if (!value) {
    throw new Error(`Secret not found for credentialRef: ${credentialRef}`);
  }

  return value;
}

module.exports = { resolveSecret };
