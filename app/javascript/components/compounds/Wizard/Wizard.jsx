import { Switch, Match } from 'solid-js';
import { createStore } from 'solid-js/store';

import { CompanyForm, RepositoryForm, AccessTokenForm } from '../../../components';
import { createModal, createFlash } from '../../molecules';

import { createCompanyRequest } from '../Company/requests/createCompanyRequest';
import { createRepositoryRequest } from '../Repository/requests/createRepositoryRequest';
import { createAccessTokenRequest } from '../AccessToken/requests/createAccessTokenRequest';

export const Wizard = (props) => {
  const [pageState, setPageState] = createStore({
    companyModalIsOpen: true,
    repositoryModalIsOpen: false,
    accessTokenModalIsOpen: false,
    companyId: null
  });

  const { Modal, openModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const onSubmitCompany = async (formStore) => {
    if (formStore.errors) {
      renderErrors(formStore.errors);
      return;
    }

    const result = await createCompanyRequest({ ...formStore, userId: props.accountId });

    if (result.errors) renderErrors(result.errors);
    else setPageState({
      ...pageState,
      companyModalIsOpen: false,
      repositoryModalIsOpen: true,
      companyId: result.result.id
    });
  }

  const onSubmitRepository = async (formStore) => {
    if (formStore.errors) {
      renderErrors(formStore.errors);
      return;
    }

    const result = await createRepositoryRequest(formStore);

    if (result.errors) renderErrors(result.errors);
    else setPageState({
      ...pageState,
      repositoryModalIsOpen: false,
      accessTokenModalIsOpen: true
    });
  }

  const onSubmitAccessToken = async (formStore) => {
    if (formStore.errors) {
      renderErrors(formStore.errors);
      return;
    }

    const result = await createAccessTokenRequest({ payload: formStore, id: pageState.companyId, tokenable: 'companies' });

    if (result.errors) renderErrors(result.errors);
    else window.location.reload();
  }

  return (
    <>
      <button class="btn-primary hidden sm:block" onClick={openModal}>Create company</button>
      <button class="btn-primary sm:hidden" onClick={openModal}>+</button>
      <Modal>
        <Switch>
          <Match when={pageState.companyModalIsOpen}>
            <div class="flex flex-col items-center">
              <h1 class="mb-2">New Company</h1>
              <p class="mb-8 text-center">Company is just abstraction for collection of repositories belongs to one group with similar settings</p>
              <CompanyForm submitText="Next" onSubmit={onSubmitCompany} />
            </div>
          </Match>
          <Match when={pageState.repositoryModalIsOpen}>
            <div class="flex flex-col items-center">
              <h1 class="mb-2">New Repository</h1>
              <p class="mb-8 text-center">Repository is just abstraction of your real repository. Link must be real, title - anything you want.</p>
              <RepositoryForm
                companyId={pageState.companyId}
                companies={[]}
                providers={props.providers}
                submitText="Next"
                onSubmit={onSubmitRepository}
              />
            </div>
          </Match>
          <Match when={pageState.accessTokenModalIsOpen}>
            <div class="flex flex-col items-center">
              <h1 class="mb-2">New access token</h1>
              <p class="mb-8 text-center">
                Visit <a href="/access_tokens" target="_blank" rel="noopener noreferrer" class="simple-link">help page</a> with guide for creating access token at Github/Gitlab and add it here.
              </p>
              <AccessTokenForm submitText="Finish" onSubmit={onSubmitAccessToken} />
            </div>
          </Match>
        </Switch>
      </Modal>
      <Flash />
    </>
  );
}
