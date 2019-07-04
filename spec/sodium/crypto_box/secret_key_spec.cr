require "../../spec_helper"
require "../../../src/sodium/crypto_box/secret_key"

private def new_key_bytes
  Sodium::CryptoBox::SecretKey.new.to_slice
end

describe Sodium::CryptoBox::SecretKey do
  it "loads keys" do
    key1 = Sodium::CryptoBox::SecretKey.new
    key2 = Sodium::CryptoBox::SecretKey.new key1.to_slice, key1.public_key.to_slice
    key1.to_slice.should eq key2.to_slice
    key1.public_key.to_slice.should eq key2.public_key.to_slice
  end

  it "recomputes the public_key" do
    key1 = Sodium::CryptoBox::SecretKey.new
    key2 = Sodium::CryptoBox::SecretKey.new key1.to_slice
    key1.to_slice.should eq key2.to_slice
    key1.public_key.to_slice.should eq key2.public_key.to_slice
  end

  it "seed keys" do
    seed = Bytes.new Sodium::CryptoBox::SecretKey::SEED_SIZE
    key1 = Sodium::CryptoBox::SecretKey.new seed: seed
    key2 = Sodium::CryptoBox::SecretKey.new seed: seed
    key1.to_slice.should eq key2.to_slice
    key1.public_key.to_slice.should eq key2.public_key.to_slice
  end

  it "authenticated easy encrypt/decrypt" do
    data = "Hello World!"

    # Alice is the sender
    alice = Sodium::CryptoBox::SecretKey.new

    # Bob is the recipient
    bob = Sodium::CryptoBox::SecretKey.new

    # Encrypt a message for Bob using his public key, signing it with Alice's
    # secret key
    box = alice.box bob.public_key
    encrypted, nonce = box.encrypt_easy data

    # Decrypt the message using Bob's secret key, and verify its signature against
    # Alice's public key
    bob.box alice.public_key do |box|
      decrypted = box.decrypt_easy encrypted, nonce: nonce

      String.new(decrypted).should eq(data)
    end
  end

  it "unauthenticated seal encrypt/decrypt" do
    data = "foo bar"

    # Bob is the recipient
    bob = Sodium::CryptoBox::SecretKey.new

    # Encrypt a message for Bob using his public key.  No signature.
    encrypted = bob.public_key.encrypt data

    # Decrypt the message using Bob's secret key.
    decrypted = bob.decrypt encrypted

    String.new(decrypted).should eq(data)
  end
end
