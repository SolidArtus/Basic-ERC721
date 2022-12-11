Ecrire un Smart-Contract pour créer ses premiers NFTs
=====================================================


L'article complet et reformatté est disponibles à [cette addresse ](https://medium.com/@asertu3/ecrire-un-smart-contract-pour-cr%C3%A9er-ses-premiers-nfts-eb0b364b8954)  sur Medium : 
----

Vous n’avez pas pu louper la folie des NFTs qui a agité investisseurs et médias depuis 2021. Bien qu’existant depuis quelques années, le confinement nous a laissé sur les bras des revenus impossible à dépenser dans nos occupations habituelles, et beaucoup se sont tournés vers des actifs intangibles : des titres de propriétés d’objets numériques garantis par la blockchain, les fameux NFTs.

Ce tutoriel va vous aider à comprendre comment ils fonctionnent d’un point de vue technique, en créant votre première collection. Il s’agit d’un Smart-Contrat, qui possède des attributs permettant de tracer dans un registre l’appartenance à des objets prédéfinis.

Prérequis
=========

Vous aurez besoin de connaître les bases de Solidity et l’outil Remix. Vous trouverez un tutoriel par rapport à ce dernier sur mon précédent post. Vous aurez aussi besoin d’un wallet du type Metamask.

> ℹ️ — Pour des questions de praticité, nous allons déployer notre collection de NFT sur la blockchain Polygon, elle permet d’avoir plus de rapidité dans les transactions et les coûts sont moins élevés.

Nous allons procéder en différentes étapes dans ce tutoriel :

*   Création du smart-contrat de notre NFT
*   Upload de nos œuvres sur IPFS
*   Création et approvisionnement d’un wallet sur l’environnement de test de la blockchain Polygon
*   Initialisation du contrat
*   Découverte d’OpenSea

Création du Smart-Contrat
=========================

Dans cette première partie, nous allons créer le code qui nous permettra de définir ces jetons non fongibles. En réalité, la majeure partie du code a déjà été écrite, et plutôt que de réinventer la roue, nous allons réutiliser du code déjà audité et donc sans faille connue à ce jour comme base pour créer nos NFTs. Le code d’un contrat gérant ces NFTs est un standard dans la communauté Ethereum qui porte le doux nom de contrat ECR-721.

Commençons la pratique :

> 📌 Allez dans Remix et créer un nouveau Workspace tiré du template ERC-721 :

[Remix - Ethereum IDE](https://remix.ethereum.org/)Création de projet ERC-721

Certaines fonctions peuvent être implémentées en cochant simplement ces cases. Pour nous faciliter le travail, nous allons importer les attributs suivants :

*   _Mintable_ importe les fonctions nous permettant de gérer le _Mint_, c’est à dire génération des tokens.
*   _Burnable_ importe les fonctions liées à la destruction des tokens.

Initialisation du code

Une fois créé, votre fichier _MyToken_ est créé. Analysons ce code, il y a trois parties importantes :

*   La gestion des bibliothèques externes, qui contient les standards de gestion de contrat ERC721;
*   L’initialisation du contrat qui contient le nom et les initiales du jeton créé. Vous pouvez les modifier si vous le désirez;
*   Une fonction a été automatiquement initialisée : _\_safeMint(address, uint256)_ qui nous permet de créer un token, à partir de deux paramètres : l’adresse du futur propriétaire de l’objet qui sera créé et le numéro de cet objet.

Nous avons la base, mais manquons encore de fonctions pour créer nos premiers NFTs. Vous allez avoir besoin de quelques bibliothèques en plus,

> 📌 Ajoutez ces importations au début du code :

```
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";  
import "@openzeppelin/contracts/utils/Counters.sol"; 
```

Elles nous permettent de récupérer des fonctions clés pour le stockage des images et leurs caractéristiques. Notre contrat doit ensuite hériter de ces importations, la ligne de déclaration de contrat devient :

```
contract MyToken is ERC721, ERC721Burnable, ERC721URIStorage, Ownable {
```

Enfin tous ces héritages nous obligent à créer certaines fonctions et attributs à notre contrat pour qu’il puisse fonctionner correctement,

> 📌 Ajoutez les fonctions suivantes pour avoir un contrat standard ERC721

*   Un compteur de nombre de NFT générés

```
using Counters for Counters.Counter;  
Counters.Counter private _tokenIdCounter;
```

*   Une fonction de desctruction :

```
 function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {  
        super._burn(tokenId);  
   }
```

*   Une fonction pour récupérer le contenu de nos NFTs.

```
function tokenURI(uint256 tokenId)  
        public  
        view  
        override(ERC721, ERC721URIStorage)  
        returns (string memory)  
    {  
        return super.tokenURI(tokenId);  
    }  
}
```

Vous pouvez d’ores et déjà compiler et déployer votre contrat dans un environnement virtuel pour commencer à interagir avec.

> 📌 Explorez toutes les fonctions et essayer de comprendre à quoi elles peuvent bien servir.

Interface de votre contrat ERC721 dans Remix

Vous pouvez _Minter_ (générer) un NFT en utilisant la fonction _safe_mint_, en mettant en paramètre l’adresse qui vous a servi à déployer dans Remix, et le numéro 0 : l’identifiant du NFT que vous voulez générer. Observez maintenant le solde de votre compte avec la fonction _BalanceOf_, vous devriez voir que vous avez 1 token associé à votre compte.

Félicitations, vous êtes propriétaire d’un NFT ! Allons voir ce qu’il contient en appliquant la fonction _TokenURI_ avec le numéro de ce NFT (0).

C’est une chaîne de caractère vide, pas très intéressante…

Contenu de votre jeton

> 📌 Maintenant, essayez de minter de nouveau le NFT ayant pour id 0.

Vous devriez voir une belle erreur, en effet un NFT est unique et ne peut pas être dupliqué, d’où l’erreur. Nous allons donc créer une fonction de création de jeton plus sécurisée, pour éviter ce genre de mésaventure.

> 📌 Essayez d’écrire le code tout seul, vous aurez besoin d’une fonction _safe_mint(address)_ qui créé un jeton vers une adresse entrée en paramètres, ce jeton portera pour identifiant le 1er numéro disponible. Vous pouvez aussi définir un nombre maximal de jetons qu’il est possible de créer dans votre contrat, on ne devrait pas pouvoir en créer plus.
> 
> A vos clavier !

🔍 Voici la solution

```
uint256 MAX_SUPPLY = 6;  
  
    function safeMint(address to) public {  
        // Le compteur vérifie le numéro de jeton actuel  
        uint256 tokenId = _tokenIdCounter.current();  
        require(tokenId <= MAX_SUPPLY, "Plus de tokens disponibles" );  
        // On l'incrémente pour le prochain jeton   
        _tokenIdCounter.increment();  
        // Il créé le token, en appelant la fonction _safeMint  
        _safeMint(to, tokenId);  
    }
```

A présent, vous ne pouvez plus créer deux fois le même NFT, vous pouvez essayez !

Nous allons dans la partie suivante, ajouter du contenu à nos jetons.

Ajouter des fichiers sur l’IPFS
===============================

Notre contrat ERC-721 sera déployé sur la blockchain Polygon et aussi longtemps qu’elle aura des utilisateurs, ce contrat sera accessible. En revanche, comment faire pour que l’image et le contenu de nos NFTs le soient aussi ?

Logo de l’IPFS

Le système de fichier interplanétaire (IPFS) peut nous aider à répondre à cette problématique. Il s’agit d’un réseau de stockage en _pair à pair_ qui nous permet d’uploader des fichiers et de les rendre accessibles dans le monde entier via une URL. C’est sur ce réseau que nous allons déployer les images de nos NFTs, préparez toutes les images à uploader dans un dossier. Renommez vos images de telle sorte que leurs noms ne soient plus qu’un numéro et l’extension du fichier (exemple 0.jpeg, 1.jpeg, 2.jpeg, etc…) Cela permettra à votre smart-contrat de toujours savoir quel est le prochain fichier à utiliser pour une nouvelle image.

Ensuite, vous devrez télécharger la dernière version du logiciel vous permettant de faire cet upload :

[Releases · ipfs/ipfs-desktop](https://github.com/ipfs/ipfs-desktop/releases)

> 📌 Installez le logiciel adapté à votre système d’exploitation.
> 
> ️ ℹ️ — Pour des questions de simplicité, nous utiliserons le logiciel à télécharger sur votre OS, mais sachez qu’il existe d’autre manière d’utiliser l’IPFS.

Application de bureau de IPFS

> 📌 Allez dans la section _File_ de votre logiciel et cliquez sur _importer_, sélectionnez le dossier contenant vos images, et HOP, elles sont désormais dans l’IPFS. De mon côté, je vais y déposer 6 images en _.jpg_ créées par un talentueux ami graphiste.

Import des images dans l’IPFS

Pour obtenir les liens d’accès à vos images, vous pouvez simplement copiez le lien avec _share link_ ou _partager le lien_, du dossier que vous venez de transférer, il vous permet de trouver l’URL à laquelle votre dossier est accessible. Le premier fichier de ce dossier est accessible à ce lien auquel on ajoute : “/” + le nom de votre fichier . Par exemple le lien que m’a généré IPFS pour mon fichier est : [https://ipfs.io/ipfs/QmQeHsZjRuH4hGHGUojH5JeVUZXdyBxPGCuAG52EZSbBZ5](https://ipfs.io/ipfs/QmQeHsZjRuH4hGHGUojH5JeVUZXdyBxPGCuAG52EZSbBZ5), donc ma première image sera acessible ici : [https://ipfs.io/ipfs/QmQeHsZjRuH4hGHGUojH5JeVUZXdyBxPGCuAG52EZSbBZ5/0.jpg](https://ipfs.io/ipfs/QmQeHsZjRuH4hGHGUojH5JeVUZXdyBxPGCuAG52EZSbBZ5/0.jpg)

> ️ ℹ️ — Vous pouvez utiliser les 6 images importées par mes soins pour votre exercice.

Maintenant, nous allons lier les NFTs vides du smart-contract à ces images fraîchement upoladées. Nous allons pour cela écrire une fonction g_etTokenURI(uint256)_ qui permet, à partir d’un _tokenId_, de générer la chaîne de caractère décrivant le nouveau token.

Exercice 1
----------

> 📌 Vous allez essayer d’écrire la fonction tout seuls avec un peu d’aide. Voici la structure de la fonction :

```
function getTokenURI(uint256 tokenId) public pure returns (string memory){  
        bytes memory dataURI = abi.encodePacked(  
            '{',                  
                '"name": //A compléter : Trouvez un nom pour l image                 
                '"description": //A compléter :description de la collection   
                '"image": //A compléter :Ecrivez ici le lien de votre image pour le tokenId donné  
            '}'  
        );  
        return string(  
            abi.encodePacked(  
                "data:application/json;base64,",  
                Base64.encode(dataURI)  
            )  
        );  
    }
```

Pour utiliser la fonction _Base64.encode_, il vous faudra utiliser la ligne d’import suivante pour ajouter le module à votre contrat, rangez la avec les autres lignes d’import.

```
import "@openzeppelin/contracts/utils/Base64.sol";
```

La fonction _GetTokenURI(uint256)_ doit renvoyer le contenu du token, qui n’est autre qu’une chaîne de caractère au format JSON avec trois paramètres:

*   le nom du token (nous l’appellerons “#N°TOKEN”)
*   Une rapide description de la collection.
*   l’image, qui sera le lien IPFS de l’image ayant pour identifiant ce numéro. Voici plusieurs aides pour votre code :

> ️ ℹ️ — La fonction _abi.encodePacked(string)_, prend en parmètres autant de chaines de caractères que nécessaire et les concatène entre elles.
> 
> ️ ℹ️ — Il existe une fonction _Strings.toString(uint256)_ qui transforme un uint256 en chaine de caractère.
> 
> ️ ℹ️ — Un format valide de JSON est au format ci dessous :

```
{  
"name":"#6",  
"description":"description de votre collection"  
"image":"https://ipfs.io/ipfs/QmQeHsZjRuH4hGHGUojH5JeVUZXdyBxPGCuAG52EZSbBZ5/6.jpg"  
}
```

Exercice 2
----------

> 📌 Le second exercice consiste à compléter la fonction _safe_mint(uint256)_ précédemment écrite pour définir le contenu de notre NFT à son initialisation. Pour cela, nous allons appeler la fonction :

```
_setTokenURI(tokenId, contenu_du_token)
```

Le contenu du token est celui généré dans la fonction précédemment écrite.

Essayez maintenant de compléter cette la fonction _safeMint(uint256)_. Elle peut être terminée en ajoutant une ou deux lignes à son code précédent.

Solution
--------

```
 function safeMint(address to) public {  
        // Le compteur vérifie le numéro de jeton actuel  
        uint256 tokenId = _tokenIdCounter.current();  
        require(tokenId <= MAX_SUPPLY, "Plus de tokens disponibles" );  
        // On l'incrémente pour le prochain jeton   
        _tokenIdCounter.increment();  
        // Il créé le token, en appelant la fonction _safeMint  
        _safeMint(to, tokenId);  
        // select the Uri  
        string memory itemUri = getTokenURI(tokenId);  
        //add it to the token  
        _setTokenURI(tokenId, itemUri);  
    }
```

Déploiement
-----------

Vous aviez trouvé ? Félicitations ! Vous pouvez dès lors essayer de déployer votre nouveau contrat et interagir avec lui. Vérifiez nottament que vous avez bien une chaîne de caractère encodée en tant que _TokenURI_ du jeton 0.

Interface de Remix avec le contrat complet redéployé

Bravo ! Vous avez déployé votre contrat en local. Passons maintenant au niveau supérieur en déployant ce contrat sur une blockchain de test : _Polygon Mumbai_.

Déploiement sur Polygon
=======================

La blockchain Polygon utilise le même moteur d’interprétation des smart-contrats qu’Ethereum et sans rentrer dans trop de détail ici, le code créé dans la partie précédente de ce tutoriel fonctionnera de la même manière sur Polygon et Ethereum, le premier est cependant est plus rapide et moins onéreux, mais moins sécurisé. C’est donc le support que nous avons choisi pour nos NFTs.

Afin de déployer sur la blockchain de test de Polygon : _Mumbai_, nous allons y connecter notre wallet (par exemple Metamask), puis y déposer des MATICs (monnaie de _Polygon_, équivalent à _l’Ether_ pour _Ethereum_). Nous pourrons ainsi payer les frais de transactions des opérations que nous nous apprêtons à réaliser sur _Polygon_.

Interface de ChainList

Connectez le réseau Mumbai à votre Wallet
-----------------------------------------

[Chainlist](https://chainlist.org/)

> 📌 Pour cela, rendez vous sur le site _ChainList.org_, qui vous permet de connecter facilement un grand nombre de blockchain à votre wallet. Recherchez le réseau _Mumbai_ en prenant soin d’inclure les testsnets dans la recherche. Cliquez ensuite sur “_Connect Wallet_” puis “_Add to Metamask_”, Signez la transaction sur votre Metamask et changez de réseau. Vous avez relié votre wallet au Testnet de Polygon !

Ajout de la chaine à Metamask

Ajout de jetons de paiement sur votre compte Mumbai
---------------------------------------------------

Maintenant, il vous faut des sous ! Allez sur un “_faucet_”, c’est à dire un site qui vous donne gratuitement des jetons de paiement pour utiliser testnet. Par exemple, allez sur :

[Polygon Faucet](https://faucet.polygon.technology/)

> 📌 Copiez l’adresse de votre compte Mumbai et entrez la dans l’adresse du faucet.

Copie de l’adresse de votre compte Mumbai dans MetamaskInterface du faucet Mumbai

Après quelques secondes, vous devriez recevoir les jetons pour payer les frais de transaction. Vous êtes prêt à faire des dépenses sur le testnet de Polygon.

Initialisation du contrat
=========================

Bien, récapitulons, nous avons un contrat pouvant contenir des NFTs liés à des images, nous avons aussi créé un compte Polygon, sur lequel nous avons des MATICs, qui nous permettent d’interagir avec cette blockchain. Si vous avez bien suivi, notre prochaine étape est de déployer notre contrat sur cette blockchain.

> 📌 En premier lieu, il faut que Remix comprenne sur quel réseau nous souhaitons déployer notre contrat, vous devez donc sélectionner l’environnement : “_Injected Provider — Metamask_” dans l’onglet “_Deploy and Run_” de remix :

Selection du réseau de déploiement sur Remix

Cela permet à votre wallet de selectionner avec quel réseau vous allez interagir.

Cliquez sur “_deploy_” dans Remix, votre Metamask vous demande ensuite de confirmer si vous voulez payer les frais de transaction. Si vous êtes bien sûrs de vous, confirmez.

Demande de confirmation de la transaction dans Metamask

Attendez quelques secondes, puis … la transaction est confirmée !

> ️ℹ — Il est possible que la transaction ne fonctionne pas si le montant calculé par Metamask pour les frais de transaction sont trop faibles. Pour palier à ce problème, augmentez les frais que vous allez payer en MATICs, en cliquant sur : MODIFIER >> Modifier le prix du carburant suggéré, et augmentez le montant maximal des frais de transaction, avant de confirmer. Répétez plusieurs fois cette opération , jusqu’à ce que la transaction soit acceptée. Cela est du au frais de gaz mal calculés par Metamask.

En cas d’erreur, augmentez la valeur du montant max des frais de transaction

Vous avez déployé votre contrat ! D’ores et déjà, le contrat est disponible sur la plateforme PolygonScan :

[TESTNET Polygon (MATIC) Blockchain Explorer](https://mumbai.polygonscan.com/)

C’est un site qui permet de scanner la blockchain Polygon. Vous connaissez peut-être _Etherscan_ qui permet d’observer toutes les transactions qui sont réalisées dans le réseau Ethereum ou d’observer le contenu de toutes les addresses du réseau, et bien _PolygonScan_ a la même utilité sur le réseau Polygon.

Vous pouvez trouver l’adresse à laquelle se trouve désormais votre contrat sur le réseau dans Remix.

Addresse du contrat déployé dans remix à rechercher dans PolygonScan

> 📌 Copiez cette adresse pour la rechercher dans PolygonScan. Vous allez être dirigé sur une page contenant toutes les interactions avec votre contrat. En l’occurrence, vous trouverez seulement l’initialisation du contrat, car nous avons eu une seule transaction liée à notre contrat.
> 
> 📌 Ajoutons une transaction en _mintant_ le premier NFT du contrat. Retournez sur Eemix et utilisez la fonction s_afeMint(address)_, avec l’adresse de votre compte en paramètres pour devenir le premier propriétaire, vous devrez encore une fois payer les frais de transaction.

Vous venez d’interagir avec le contrat, vous pouvez aller la voir dans PolygonScan, sur la page du contrat si vous voyez bien cette nouvelle transaction.

Voir nos NFTs dans OpenSea
--------------------------

Pour vérifier que tout s’est bien déroulé et finalement observer notre collection nouvellement créée, nous allons utiliser un site bien connu des collectionneurs : _OpenSea_. Ce site scanne les blockchains à la recherche des contrats respectant la norme ERC-721. OpenSea lit ensuite les informations contenues dans chaque NFT pour nous l’afficher : son nom, son image, son propriétaire, etc…

Cherchons notre contrat sur OpenSea. En premier lieu, il faut se rendre sur le site scannant les blockchains de test et rechercher l’adresse du contrat que nous avons déployé.

[https://testnets.opensea.io/fr](https://testnets.opensea.io/fr)

Si tout s’est déroulé sans encombre, vous devriez voir une page de ce format:

Page de la collection NFT (ou du contrat déployé) dans OpenSea

Cliquez sur le premier NFT de la collection afin de voir le détail de cette image. Vous y trouverez les informations écrites dans l’URI de votre jeton, redisposé dans le site OpenSea. Vous devriez voir que vous êtes le propriétaire de ce NFT si vous connectez votre Metamask.

Conclusion
==========

Bravo !! Vous avez fait un excellemment travail, vous avez effectué toutes les taches de ce tutoriel. Vous avez écrit un contrat ERC721, uploadé des fichiers sur l’IPFS, déployé votre contrat sur le testnet de Polygon et observé vos NFTs sur OpenSea.

Il y a encore beaucoup de choses à découvrir avant de comprendre la densité des possibilités des NFTs sur une blockchain, mais ce tutoriel a pu vous permettre de comprendre comment ils fonctionnaient d’un point de vue technique.

Pour vous donner quelques pistes pour approfondir le sujet sachez que les metadonnées peuvent contenir d’autres informations (nous avions juste un nom, une description et une image), vous pouvez ajouter des éléments supplémentaires comme un attribut “animal”, qui prendra la valeur du nom d’un animal en fonction de ce qui apparaît sur l’image. Un bon exercice pourrait être d’uploader des fichiers au format JSONs descriptifs plutot que des images dans l’IPFS et de les relier à vos NFTs pour avoir des compléments sur ce qui apparaît dans l’image.

Bonne chance pour la suite de vos aventures !

[r/ethdev\_fr](https://www.reddit.com/r/ethdev_fr/)
