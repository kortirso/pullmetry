export const convertDateTime = (value) => (
  new Date(value).toLocaleString(
    [], { year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute:'2-digit' }
  )
);

export const convertDate = (value) => (
  new Date(value).toLocaleString(
    [], { year: 'numeric', month: 'numeric', day: 'numeric' }
  )
);

export const convertTime = (value) => (
  new Date(value).toLocaleString(
    [], { hour: '2-digit', minute:'2-digit' }
  )
);
