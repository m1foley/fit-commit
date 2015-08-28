require "fit-commit/validators/base"

module FitCommit
  module Validators
    class Tense < Base
      VERB_BLACKLIST = %w(
        adds       adding       added
        allows     allowing     allowed
        amends     amending     amended
        bumps      bumping      bumped
        calculates calculating  calculated
        changes    changing     changed
        cleans     cleaning     cleaned
        commits    committing   committed
        corrects   correcting   corrected
        creates    creating     created
        darkens    darkening    darkened
        disables   disabling    disabled
        displays   displaying   displayed
        drys       drying       dryed
        ends       ending       ended
        enforces   enforcing    enforced
        enqueues   enqueuing    enqueued
        extracts   extracting   extracted
        finishes   finishing    finished
        fixes      fixing       fixed
        formats    formatting   formatted
        guards     guarding     guarded
        handles    handling     handled
        hides      hiding       hid
        increases  increasing   increased
        ignores    ignoring     ignored
        implements implementing implemented
        improves   improving    improved
        keeps      keeping      kept
        kills      killing      killed
        makes      making       made
        merges     merging      merged
        moves      moving       moved
        permits    permitting   permitted
        prevents   preventing   prevented
        pushes     pushing      pushed
        rebases    rebasing     rebased
        refactors  refactoring  refactored
        removes    removing     removed
        renames    renaming     renamed
        reorders   reordering   reordered
        requires   requiring    required
        restores   restoring    restored
        sends      sending      sent
        sets       setting
        separates  separating   separated
        shows      showing      showed
        skips      skipping     skipped
        sorts      sorting
        speeds     speeding     sped
        starts     starting     started
        supports   supporting   supported
        takes      taking       took
        tests      testing      tested
        truncates  truncating   truncated
        updates    updating     updated
        uses       using        used
      )

      def validate_line(lineno, text, _branch_name)
        if lineno == 1 && starts_with_blacklisted_verb?(text)
          add_error(lineno, "Message must use imperative present tense.")
        end
      end

      def starts_with_blacklisted_verb?(text)
        first_word = text.split.first(2).detect { |w| w =~ /\A\w/ }
        first_word && VERB_BLACKLIST.include?(first_word.downcase)
      end
    end
  end
end
