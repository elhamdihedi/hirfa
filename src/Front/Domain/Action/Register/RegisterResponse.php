<?php

namespace Front\Domain\Action\Register;

use Front\Domain\Model\Client;

class RegisterResponse
{
    private Client $client;

    public function client()
    {
        return $this->client;
    }

    public function setClient($client)
    {
        $this->client = $client;

        return $this;
    }
}
