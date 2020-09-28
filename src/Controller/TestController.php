<?php

namespace App\Controller;

use App\Entity\User;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class TestController extends AbstractController
{
    /**
     * @Route("/test")
     */
    public function listAction(): Response
    {
        $users = $this->getDoctrine()->getRepository(User::class)
            ->findAll();

        return $this->render('test/list.html.twig', ['users' => $users]);
    }

    /**
     * @Route("/create")
     */
    public function create(): Response
    {
        $user = (new User())
            ->setEmail('PedroManual');
        $this->getDoctrine()->getManager()
            ->persist($user);
        $this->getDoctrine()->getManager()->flush();

        return $this->render('test/create.html.twig', ['user' => $user]);
    }
}
