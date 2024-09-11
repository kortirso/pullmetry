export const objectKeysToSnakeCase = (source) =>
  Object.keys(source)
    .reduce((destination, key) => {
      destination[key.replace( /([A-Z])/g, "_$1" ).toLowerCase()] = source[key];
      return destination;
    }, {});
