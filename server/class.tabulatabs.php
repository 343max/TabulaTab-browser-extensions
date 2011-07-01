<?php

define('tabulatabs_datadir', dirname(dirname(__FILE__)) . '/data/');


class Tabulatabs {
	const authDataFileId = 'auth';
	private $userId = '';
	private $clientId = '';

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

	public function verifyUserCredentials() {
		$authData = json_decode($this->readDataFile(self::authDataFileId), true);

		if ($authData['userId'] != $this->userId) return false;
		if ($authData['clientId'] != sha1($this->clientId)) return false;

		return true;
	}

	public function dieOnInvalidUserCredentials() {
		if(!$this->verifyUserCredentials()) {
			errorResponse('invalid user');
		}
	}

	public function createUser() {
		$authData = array(
			'userId' => $this->userId,
			'clientId' => sha1($this->clientId)
		);

		$this->writeDataFile(self::authDataFileId, json_encode($authData));
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