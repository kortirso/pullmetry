export const objectKeysToSnakeCase = (source) =>
  Object.keys(source)
    .reduce((destination, key) => {
      let transformedKey = key.replace(/([A-Z])/g, "_$1").toLowerCase();
      destination[transformedKey] = source[key];
      return destination;
    }, {});
