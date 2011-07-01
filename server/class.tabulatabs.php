<?php


require_once('class.tabulatabsAuthentification.php');

define('tabulatabs_datadir', dirname(dirname(__FILE__)) . '/data/');


class Tabulatabs {
	const authDataFileId = 'auth';
	private $userId = '';
	private $clientId = '';
	/**
	 * @var TabulatabsAuthentification
	 */
	private $authObject = null;

	public function __construct($userId, $clientId) {
		$this->userId = preg_replace('/[^a-zA-Z0-9]/', '', $userId);
		$this->clientId = $clientId;
	}

	public function dataFilePath($fileId) {
		return tabulatabs_datadir . $this->userId . '-' . $fileId . '.json';
	}

	public function writeDataFile($fileId, $data) {
		file_put_contents($this->dataFilePath($fileId), $data);
	}

	public function readDataFile($fileId) {
		return file_get_contents($this->dataFilePath($fileId));
	}

	public function userExists() {
		return file_exists($this->dataFilePath(self::authDataFileId));
	}

	/**
	 * @return TabulatabsAuthentification
	 */
	private function authentification() {
		if (!$this->authObject) {
			$this->authObject = new TabulatabsAuthentification($this->readDataFile(self::authDataFileId));
		}

		if (rand(0, 1000) == 1) {
			$this->writeAuthFile();
		}

		return $this->authObject;
	}

	private function writeAuthFile() {
		if (!$this->authObject)
			return false;

		$this->writeDataFile(self::authDataFileId, $this->authObject->jsonify());
	}

	public function verifyClientCredentials() {
		return $this->authentification()->verifyClient($this->clientId);
	}

	public function dieOnInvalidUserCredentials() {
		if(!$this->verifyClientCredentials()) {
			errorResponse('invalid userId or clientId');
		}
	}

	public function registerBrowser() {
		$this->authObject = new TabulatabsAuthentification();
		$this->authObject->registerBrowser($this->userId, $this->clientId);

		$this->writeAuthFile();
	}

	public function registerClient() {
		$this->authentification()->registerClient($this->clientId);
		$this->writeAuthFile();
	}

	public function claimClient() {
		$this->authentification()->claimClient($this->clientId);
		$this->writeAuthFile();
	}

	public function validReadWriteableFileId($fileId) {
		return in_array($fileId, array('browserInfo', 'browserTabs'));
	}

	public function getValueForKey($key) {
		if(!$this->validReadWriteableFileId($key)) {
			errorResponse('unkown fileId');
		}

		$filePath = $this->dataFilePath($key);

		if(!file_exists($filePath)) {
			errorResponse('file does not exist');
		}

		okayResponse(file_get_contents($filePath));
	}

	public function putValueForKey($fileId, $data) {
		if(!$this->validReadWriteableFileId($fileId)) {
			errorResponse('unkown fileId');
		}

		file_put_contents($this->dataFilePath($fileId), $data);
		okayResponse();
	}
}