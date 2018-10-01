# Configurar y desplegar una testnet de ethereum

En esta primera versión sólo se explica como configurar y desplegar una testnet en  OS X. Aun así, hay que tener en cuenta que lo único que varía son los pasos de instalación de los distintos clientes.

## Instalar Ethereum

```sh
$ brew update
$ brew upgrade
$ brew tap ethereum/ethereum
$ brew install ethereum
```

Para comprobar que funciona:

```sh
$ geth console
```

Una vez sabemos que el cliente de GoEthereum (geth) funciona se deben crear dos cuentas:

```sh
$ geth account new
```
La ejecución de este comando espera recibir una contraseña que será la que desbloquee la cuenta.

## Crear ficheros de configuración

Para configurar una red de Ethereum se debe crear un fichero conocido como \"Bloque Génesis\" en el que se especifican varios parámetros:

### myGenesis.json
```js
{
    "config": {
        "chainId": 2000,
        "homesteadBlock": 0,
        "eip155Block": 0,
        "eip158Block": 0,
        "byzantiumBlock": 0
    },
    "difficulty": "400",
    "gasLimit": "2000000",
    "alloc": {
        "b38935ab356f828df2ee27ef525d9649b9b9e18f": {
            "balance": "100000000000000000000000"
        },
        "9b0b0e4ba1e990704f46840fd42bfb3352424e49": {
            "balance": "120000000000000000000000"
        }
    }
}
```

### chainId
Identifica la cadena y se usa para evitar ataques de reinyección.

### homesteadBlock, eip155Block, eip158Block y byzantiumBlock
Relacionados con veriones y posibles forks que pueda haber en la cadena.

### dificulty
Hace referencia a la dificultad de minado. En este caso le damos una valor bajo (400) para que no tarden demasiado en generarse los bloques.

### gasLimit
Especifica el máximo gas que se puede gastar en cada transacción.

### alloc
Aquí se especifican los addresses de las cuentas generadas previamente y el balance que se le asigna a cada una (100.00 Eth y 120.00 Eth respectivamente). Para obtener esto addresses basta con ejecutar:

```sh
$ geth account list
```

## Ejecutar geth con el nuevo fichero de configuración (Bloque Génesis).

### Instanciar el directorio de datos
```sh
$ geth --datadir ./myDataDir init ./myGenesis.json
```

### Arrancar peer node de Ethereum
```sh
$ geth --datadir ./myDataDir --networkis 1234 console 2>> myEth.log
```

### Seguir los logs
Desde otro consola se pueden seguir los logs que se generen mediante:

```sh
tail -f myEth.log
```

### Copiar las claves de una de las cuentas al direcorio "myDataDir"
```sh
cp -R /<Directorio de la cuenta>/keystore/<cuenta1>. ./myDataDir/keystore/.
```

Si no se conoce el directorio en el que está almacenada la información asociada a una cuenta basta con listarla:

```sh
$ geth account list
```

Para comprobar que se ha hecho correctamente basta con ejecutar desde la console de geth:

```sh
> eth.accounts
```
ó
```sh
> personal.listAccounts
```

### Hacer que la cuenta que acabamos de añadir comience a minar bloques

Desde la consola de geth:
```sh
> miner.setEtherbase(web3.eth.accounts[0])
> miner.start()
```

Para comprobar que ha funcionado basta con comprobar el balance de la cuenta:
```sh
> eth.getBalance(eth.coinbase)
```

Si la cuenta que ha comenzado a minar era la que tenía 100.00 Eth, debería tener un saldo algo mayor que 1e+23, y si era la que tenía 120.00 Eth, el saldo debería ser algo superior a 1.2e+23.
Aun así, hasta que el minero comienza a minar pueden pasar entre 2 y 3 minutos, por tanto si no observas cambios espera :wink:

Si quisieses que dejase de minar bastaría con ejecutar desde la consola de geth:

```sh
> miner.stop()
```

## Añadir otro peer
El proceso es muy similar al anterior, pero se debe unir al peer actual. Además se debe indicar un puerto a la hora de arrancar el peer para evitar que los dos utilicen el mismo.

```sh
$ geth --datadir ./peer2DataDir init ./myGenesis.json
$ geth --datadir ./peer2DataDir --networkid 1234 --port 30304 console 2>> myEth2.log
```
Desde otro terminal debemos copiar las claves asociadas a la segunda cuenta:
```sh
$ cp -R /<Directorio de la cuenta>/keystore/<cuenta2>/. ./peer2DataDir/keystore/.
```

Para unir ambos peers primero debemos obtener la dirección del enode de la primera cuenta. Para ello, desde la primera consola de geth:
```sh
> admin.nodeInfo.enode
```
Con esta información desde la segunda consola de geth, la asociada al peer2, se debe ejecutar:
```sh
> admin.addPeer("<Valor copiado>")
```
:bangbang: En el valor copiado hay que asegurarse de que la IP no es [::], debería ser 127.0.0.1. Si no lo fuese basta con cambiarlo antes de ejecutar el comando. :bangbang:

Comprobación (desde cualquiera de los peers):
```sh
> admin.peers
```

# Despliegue e instanciación de un SmartContract

En esta sección se explica como desplegar e instanciar desde geth un SmartContract.

## Instalar compilador de solidity
```sh
$ npm install -g solc
```

## Compilar el SmartContract para generar el abi y el binario
```sh
$ solcjs --abi myContract.sol
$ solcjs --bin myContract.sol
```

## Listar el abi y el binario
```sh
$ more myContract_sol_myContract.abi
$ mode myContract_sol_myContract.bin
```

## Deplegar el contrato desde geth
Primero se debe desbolquear la cuenta desde la que se va a desplegar el SmartContract
```sh
> personal.unlockAccount(eth.accounts[0])
```

Una vez está desbloqueada la cuenta se debe introducir el abi y el binario para poder generar una instancia del SmartContract.
```sh
> var myContract = eth.contract(<Contenido del ABI>)
> var bytecode = '0x<Contenido del binario>'
> var deploy = {from: eth.accounts[0], data: bytecode, gas: 2000000}
> var myContractPartialInstance = myContract.new("<Parámetros de la función constructora del contrato>", deploy)
> var myContractInstance = myContract.at(myContractPartialInstance.address)
```
Si se utiliza el contrato proporcionado para probarlo no se deben pasar parámetros a la función constructora ya que no hay, quedando por tanto la definición de la variable myContractPartialInstance como sigue:
```sh
> var myContractPartialInstance = myContract.new(deploy)
```

Además, si en alguno de los setter diese un error del tipo \"invalid address\", para solucionarlo basta con configurar la cuenta por defecto:
```sh
> eth.defaultAccount = eth.accounts[0]
```

# MyContract

myContract.sol es un SmartContract muy básico que tiene dos funciones getter (hello() y goodBye()) y dos funciones setter (setHello() y setGoodBye()). Los setters reciben como parámetro un string.

Estas funciones se pueden llamar desde la consola de geth como sigue:

```sh
> myContractInstance.hello()
> myContractInstance.setHello("Hola")
> myContractInstance.goodBye()
> myContractInstance.setGoodBye("Adiós")
```

La primera función debería imprimir por pantalla \"Hello\", la siguiente un identificador de transacción, la tercera \"Good Bye\" y la última, igual que la segunda, un identificador de transacción.

Por último, si se desea acceder a un SmartContract desde un peer que NO lo ha desplegado habrá que instanciar dicho contrato indicando el address del SmartContract.

Para obtener el address del SmartContract, desde el cliente geth del peer que lo ha desplegado hay que ejecutar:
```sh
> myContractInstance.address
```

Para generar la nueva instancia desde el otro peer:
```sh
> var myContract = eth.contract(<Contenido del ABI>)
> var myContractInstance = myContract.at("<Address del SmartContract>")
```

:bangbang: Para poder instanciar el SmartContract la cuenta debe estar desbloqueada. :bangbang: