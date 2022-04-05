<?php

namespace Symfony6\Doctrine;

use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;
use Front\Domain\Model\Client;
use Front\Domain\Model\ClientRepository;

class DoctrineUserRepository extends ServiceEntityRepository implements ClientRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, User::class);
    }

    public function add(Client $client)
    {
        $user = new User();
        $user->setName($client->getName());
        $user->setEmail($client->getEmail());
        $this->getEntityManager()->persist($user);
        $this->getEntityManager()->flush($user);
    }

    public function update(Client $client)
    {
        $user = $this->findOneBy(['id' => $client->id()]);
        $user->setEmail($client->email());
        $user->setName($client->getName());
        $this->getEntityManager()->persist($user);
        $this->getEntityManager()->flush($user);
    }
}
