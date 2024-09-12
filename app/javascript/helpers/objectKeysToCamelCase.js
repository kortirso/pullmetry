export const objectKeysToCamelCase = (source) =>
  Object.keys(source)
    .reduce((destination, key) => {
      let transformedKey = key.replace(/([_][a-z])/ig, ($1) => { return $1.toUpperCase().replace('_', '') });
      destination[transformedKey] = source[key];
      return destination;
    }, {});
