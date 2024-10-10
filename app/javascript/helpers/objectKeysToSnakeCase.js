export const objectKeysToSnakeCase = (source) =>
  Object.keys(source)
    .reduce((acc, key) => {
      let valueIsObject = typeof source[key] === 'object' && source[key] !== null;
      let transformedKey = key.replace(/([A-Z])/g, "_$1").toLowerCase();
      acc[transformedKey] = valueIsObject ? objectKeysToSnakeCase(source[key]) : source[key];
      return acc;
    }, {});
