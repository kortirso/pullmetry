const SECONDS_IN_MINUTE = 60;
const SECONDS_IN_HOUR = 3_600;
const SECONDS_IN_DAY = 86_400;
const MINUTES_IN_HOUR = 60;
const HOURS_IN_DAY = 24;

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

export const toFormattedTime = (value) => {
  if (value === 0) return '-';
  if (value < 60) return '1m';

  const minutes = Math.floor((value / SECONDS_IN_MINUTE) % MINUTES_IN_HOUR);
  if (value < SECONDS_IN_HOUR) return `${minutes}m`;

  const hours = Math.floor((value / SECONDS_IN_HOUR) % HOURS_IN_DAY);
  if (value < SECONDS_IN_DAY) return `${hours}h ${minutes}m`;

  return `${Math.floor(value / SECONDS_IN_DAY)}d ${hours}h ${minutes}m`;
}
