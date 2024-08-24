export function FeedbackForm(props) {

  console.log('props');
  console.log(props.children);

  return (
    <>
      <div
        dangerouslySetInnerHTML={{ __html: props.children }}
      ></div>
      <p>123</p>
    </>
  );
};
