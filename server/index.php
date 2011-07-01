<?php

//if (count($_POST) == 0) $_POST = $_GET;

if (count($_POST) == 0) {
	header('Location: http://tabulatabs.com/');
	die();
}

require_once('class.tabulatabs.php');

$client = new Tabulatabs($_POST['userId'], $_POST['clientId']);

function errorResponse($errorMessage) {
	echo json_encode(array(
		'error' => $errorMessage,
		'response' => 'error'
	));

	die();
}

function okayResponse($data = null) {
	echo json_encode(array(
		'data' => $data,
		'response' => 'ok'
	 ));

	 die();
}

switch($_POST['action']) {
	case 'registerBrowser':
		if($client->userExists()) {
			errorResponse('User ID allready exists');
		} else {
			$client->registerBrowser();
			okayResponse();
		}
		break;

	case 'registerClient':
		if(!$client->userExists()) {
			errorResponse('unknown user');
		} else {
			$client->registerClient();
			okayResponse();
		}
		break;

	case 'claimClient':
		$client->dieOnInvalidUserCredentials();
		$client->claimClient();
		okayResponse();

		break;

	case 'get':
		$client->dieOnInvalidUserCredentials();
		$client->getValueForKey($_POST['key']);
		break;

	case 'put':
		$client->dieOnInvalidUserCredentials();
		$client->putValueForKey($_POST['key'], $_POST['value']);
		break;
}

errorResponse('unkown method');

?>