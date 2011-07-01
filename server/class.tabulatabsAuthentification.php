<?php

class TabulatabsAuthentification {
	public $userId;

	public $clients = array();

	public function __construct($jsonString = null) {
		if ($jsonString == null) return;

		$jsonObject = json_decode($jsonString);

		$this->userId = $jsonObject->userId;
		$this->clients = $jsonObject->clients;
	}

	public function jsonify() {
		$this->cleanupUnclaimedClients();
		$jsonObject = new stdClass();

		$jsonObject->userId = $this->userId;
		$jsonObject->clients = $this->clients;

		return json_encode($jsonObject);
	}

	public function registerBrowser($userId, $clientId) {
		$this->userId = $userId;
		$this->registerClient($clientId, false);
	}

	public function registerClient($clientId, $isUnclaimed = true) {
		$client = new stdClass();
		$client->clientId = $clientId;
		$client->isUnclaimed = ($isUnclaimed ? 1 : 0);

		if ($isUnclaimed) {
			$client->claimingTimeout = time() + 3600 * 3;
		}

		$this->clients[] = $client;
	}

	public function findClientWithClientId($clientId) {
		for ($i = 0; $i < count($this->clients); $i++) {
			if ($this->clients[$i]->clientId == $clientId) {
				if ($this->clients[$i]->isUnclaimed and $this->clients[$i]->claimingTimeout < time()) {
					return null;
				} else {
					return $this->clients[$i];
				}
			}
		}

		return null;
	}

	public function verifyClient($clientId) {
		$client = $this->findClientWithClientId($clientId);

		if (!$client) {
			return false;
		}

		return true;
	}

	public function claimClient($clientId) {
		$client = $this->findClientWithClientId($clientId);

		if (!$client) {
			errorResponse('unknown client id');
		}

		if (!$client->isUnclaimed) {
			errorResponse('client is allready claimed');
		}

		$client->isUnclaimed = 0;
		unset($client->claimingTimeout);
	}

	public function cleanupUnclaimedClients() {
		$newClients = array();

		foreach($this->clients as $client) {
			if (!$client->isUnclaimed) {
				$newClients[] = $client;
			} else {
				if ($client->claimingTimeout > time()) {
					$newClients[] = $client;
				}
			}
		}

		$this->clients = $newClients;
	}
}