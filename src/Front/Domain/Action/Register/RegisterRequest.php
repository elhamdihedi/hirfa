<?php

namespace Front\Domain\Action\Register;

class RegisterRequest
{
    public bool $isPosted = false;
    public null|string $name;
    public null|string $email;
}
