<?php

declare(strict_types=1);

namespace Front\Domain\Model;

interface ClientRepository
{
    public function add(Client $user);

    public function update(Client $user);
}
