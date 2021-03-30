pragma solidity ^0.5.15;

import "./SafeMath.sol";

contract NTF {
  using SafeMath for uint;

  struct obra {
    address creador;
    address propietario;
    address subasta;
    uint precio;
    bool en_venta;
    uint fin_subasta;
    string meta_datos;
    string urls;
  }

  struct Cuenta {
    bool registered;
    uint blockeCreacion;
    obra[] mis_obras;
  }

  uint public obras_registradas;
  uint public cuentas_registradas;

  uint public costo_registro = 10 trx;
  address payable public owner;

  mapping (address => Cuenta) public cuentas;
  mapping (string => obra) public obras;


  constructor() public {
    owner = msg.sender;
  }

  function registarObra(string memory _datos, string memory _urls, uint _valor) public payable returns(bool) {

    require (msg.value >= costo_registro);

    if (!cuentas[msg.sender].registered){
      cuentas[msg.sender].registered = true;
      cuentas[msg.sender].blockeCreacion = block.number;

      owner.transfer(costo_registro.mul(90).div(100));

      cuentas_registradas++;
    }


    require (cuentas[msg.sender].registered);

    cuentas[msg.sender].obras.push(obra( msg.sender, msg.sender, msg.sender, _valor, false, block.number, _datos, _urls));
    obras_registradas++;

    return (true);

  }

  function comprarObra(address _propietario, uint _obra) public payable returns(bool) {
    require (cuentas[msg.sender].registered);
    require (cuentas[_propietario].registered);
    require (cuentas[_propietario].obras[_obra].en_venta);
    require (msg.value == cuentas[_propietario].obras[_obra].precio);
    require (block.number >= cuentas[_propietario].obras[_obra].fin_subasta);

    _propietario.transfer(msg.value.mul(90).div(100));
    owner.transfer(msg.value.mul(10).div(100));

    cuentas[_propietario].obras[_obra].propietario = msg.sender;
    address _creador = cuentas[_propietario].obras[_obra].creador;
    string memory _datos = cuentas[_propietario].obras[_obra].meta_datos;
    string memory _urls = cuentas[_propietario].obras[_obra].urls;

    cuentas[msg.sender].obras.push(obra( _creador, msg.sender, msg.sender, msg.value, false, block.number, _datos, _urls));

    return true;

  }

  function comprarObraEnSubasta(address _propietario, uint _obra) public payable returns(bool) {
    require (cuentas[msg.sender].registered);
    require (cuentas[_propietario].registered);
    require (msg.value > cuentas[_propietario].obras[_obra].precio);
    require (block.number <= cuentas[_propietario].obras[_obra].fin_subasta);

    owner.transfer(msg.value.mul(10).div(100));

    address _creador = cuentas[_propietario].obras[_obra].creador;
    address _propietario = cuentas[_propietario].obras[_obra].subasta;
    uint _fin_subasta = cuentas[_propietario].obras[_obra].fin_subasta;
    string memory _datos = cuentas[_propietario].obras[_obra].datos;
    string memory _urls = cuentas[_propietario].obras[_obra].urls;


    cuentas[_propietario].obras[_obra].subasta = msg.sender;

    cuentas[msg.sender].obras.push(obra( _creador, _propietario, msg.sender, msg.value, false, _fin_subasta, _datos, _urls));

    return true;

  }

  function reclamarObraEnSubasta(address _propietario, uint _obra) public payable returns(bool) {
    require (cuentas[msg.sender].registered);
    require (cuentas[_propietario].registered);
    require (msg.value > cuentas[_propietario].obras[_obra].precio);
    require (block.number <= cuentas[_propietario].obras[_obra].fin_subasta);

    owner.transfer(msg.value.mul(10).div(100));

    address _creador = cuentas[_propietario].obras[_obra].creador;
    address _propietario = cuentas[_propietario].obras[_obra].subasta;
    uint _fin_subasta = cuentas[_propietario].obras[_obra].fin_subasta;
    string memory _datos = cuentas[_propietario].obras[_obra].datos;
    string memory _urls = cuentas[_propietario].obras[_obra].urls;


    cuentas[_propietario].obras[_obra].subasta = msg.sender;

    cuentas[msg.sender].obras.push(obra( _creador, _propietario, msg.sender, msg.value, false, _fin_subasta, _datos, _urls));

    return true;

  }


  function venderObra(address _destinatario, uint _obra) public returns(bool) {
    require (cuentas[msg.sender].registered);
    require (cuentas[_destinatario].registered);

    cuentas[msg.sender].obras[_obra].propietario = _destinatario;
    address _creador = cuentas[_propietario].obras[_obra].creador;
    uint _precio = cuentas[msg.sender].obras[_obra].precio;
    string memory _datos = cuentas[msg.sender].obras[_obra].datos;
    string memory _urls = cuentas[_propietario].obras[_obra].urls;

    cuentas[_destinatario].obras.push(obra(_creador, _destinatario, _destinatario, _precio, false, _fin_subasta, _datos, _urls));

    return true;

  }

  function nuevoCostoregistro(uint num)public{
    require (msg.sender == owner);
    costo_registro = num;
  }


}
