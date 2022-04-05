<?php

declare(strict_types=1);

namespace Front\Domain\Action\Register;

use Front\Domain\Model\Client;
use Front\Domain\Model\ClientRepository;

class Register
{
    private ClientRepository $clientRepository;

    public function __construct(ClientRepository $repository)
    {
        $this->clientRepository = $repository;
    }

    public function execute(RegisterRequest $request, RegisterPresenter $presenter)
    {
        $response = new RegisterResponse();
        if ($request->isPosted && $this->validateRequest($request, $response)) {
            $client = new Client();
            $client->setEmail($request->email);
            $client->setName($request->name);
            $this->userRepository->add($client);
        }

        $presenter->present($response);
    }
    private function validateRequest(RegisterRequest $request, RegisterResponse $response)
    {
        try {
            Assert::lazy()
                ->that($request->firstName, 'firstName')->notEmpty('error-notEmpty')->string('error-string')
                ->that($request->lastName, 'lastName')->notEmpty('error-notEmpty')->string('error-string')
                ->that($request->email, 'email')->notEmpty('error-notEmpty')->email('invalid-email')
                ->that($request->phoneNumber, 'phoneNumber')->notEmpty('error-notEmpty')
                ->that($request->password, 'password')->notEmpty('error-notEmpty')->string('error-string')
                ->that($request->companyName, 'companyName')
                ->that($request->store, 'store')->notEmpty('error-notEmpty')->choice(Store::$all, 'error-choice')
                ->verifyNow();

            return true;
        } catch (LazyAssertionException $e) {
            foreach ($e->getErrorExceptions() as $error) {
                $response->addError($error->getPropertyPath(), $error->getMessage());
            }

            return false;
        }
    }
}
