<?php

namespace Front\Presentation;

use Front\Domain\Action\Register\RegisterPresenter;
use Front\Domain\Action\Register\RegisterResponse;

class RegisterHtmlPresenter implements RegisterPresenter
{
    private RegisterHtmlViewModel $viewModel;

    public function present(RegisterResponse $response): void
    {
        $this->viewModel = new RegisterHtmlViewModel();
        /*
                foreach ($response->notification()->getErrors() as $error) {
                    $this->viewModel->errors[$error->fieldName()] = $error->message();
                }*/
    }

    public function viewModel()
    {
        return $this->viewModel;
    }
}
