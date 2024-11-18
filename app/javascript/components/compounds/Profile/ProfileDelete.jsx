import { Dropdown } from '../../molecules';
import { csrfToken } from '../../../helpers';

export const ProfileDelete = (props) => {
  let deleteForm;

  const onDeleteAccount = (event) => {
    event.preventDefault();
    event.stopPropagation();

    if (window.confirm('Are you sure you wish to delete account?')) deleteForm.submit();
  };

  return (
    <div class="box mb-4 p-8">
      <h2 class="mb-2">Delete account</h2>
      <p class="mb-6 light-color">You can delete your account. This action is not revertable. All your identities, companies, repositories, access tokens and statistics will be destroyed with no chance of recovery. Only information about your subscriptions will be saved.</p>
      <form
        ref={deleteForm}
        method="post"
        action={props.destroyLink}
        class="flex justify-center"
        onSubmit={(event) => onDeleteAccount(event)}
      >
        <input type="hidden" name="_method" value="delete" autoComplete="off" />
        <input
          type="hidden"
          name="authenticity_token"
          value={csrfToken()}
          autoComplete="off"
        />
        <button
          type="submit"
          class="btn-danger btn-small"
          onClick={(event) => event.stopPropagation()}
        >Delete account</button>
      </form>
    </div>
  )
}
