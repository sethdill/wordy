# wordy
Wordnik client, demo project only

To run this demo, you must have a (free) [Wordnik account](https://www.wordnik.com/signup).

1. Run the app in the simulator or on your phone

2. Enter your credentials. (They're stored in the keychain.)

3. After you're logged in, type 3 or more letters in the text field.

  * Search results are fetched and listed immediately, as you type.

  * Enter a partial word and the results include all words that begin with that word.

  * If exact match, only that word is shown.

  * Use asterisks to indicate "anything here". So "foo\*" for any word beginning with "foo", and "\*foo\*" for any word that contains "foo" anywhere.

4. Tap on a word in the results list to *do nothing*. __I wasn't writing a full client, after all!__

## Testing

Only the results parser has any testing coverage. It's just a demo app, after all.