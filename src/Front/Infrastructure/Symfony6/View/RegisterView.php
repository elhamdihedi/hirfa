<?php

declare(strict_types=1);

namespace Symfony6\View;

use Front\Domain\Action\Register\RegisterRequest;
use Front\Presentation\RegisterHtmlViewModel;
use Symfony\Component\Form\FormFactoryInterface;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\RouterInterface;
use Twig\Environment;

class RegisterView
{
    private $twig;
    private $formFactory;
    private $router;

    public function __construct(Environment $twig, FormFactoryInterface $formFactory, RouterInterface $router)
    {
        $this->twig = $twig;
        $this->formFactory = $formFactory;
        $this->router = $router;
    }

    public function render(RegisterRequest $registerInput, RegisterHtmlViewModel $viewModel): Response
    {
        $form = $this->formFactory->createBuilder(\Symfony6\Form\RegisterType::class, $registerInput)->getForm();

        return new Response($this->twig->render('register.html.twig', ['form' => $form->createView(), 'viewModel' => $viewModel]));
    }
}
