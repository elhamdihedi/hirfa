<?php

declare(strict_types=1);

namespace Symfony6\Controller;

use Front\Domain\Action\Register\Register;
use Front\Domain\Action\Register\RegisterRequest;
use Front\Presentation\RegisterHtmlPresenter;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony6\View\RegisterView;

class RegisterController
{
    #[Route('/register', name: 'hirfa_register')]
    public function __invoke(
        Request $request,
        Register $registerCase,
        RegisterRequest $registerRequest,
        RegisterHtmlPresenter $registerPresenter,
        RegisterView $registerView,
        RegisterRequest $form2request
    ) {
        $registerRequest->name = $request->request->get('name');
        $registerRequest->email = $request->request->get('email');
        $registerCase->execute($registerRequest, $registerPresenter);
        return $registerView->render($form2request, $registerPresenter->viewModel());
    }
}
