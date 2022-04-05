<?php

declare(strict_types=1);

namespace Front\Domain\Action\Register;

interface RegisterPresenter
{
    public function present(RegisterResponse $response): void;
}
